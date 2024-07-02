import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/firebase/firebase_auth_provider.dart';
import 'package:health_sentry/app/core/firebase/firebase_options.dart';
import 'package:health_sentry/app/core/local_storage/local_data.dart';
import 'package:health_sentry/app/core/utils/validator.dart';
import 'package:health_sentry/app/features/accounts/model/user.dart' as user;
import 'package:health_sentry/app/features/accounts/model/user.dart';
import 'package:health_sentry/app/features/accounts/providers/accounts_provider.dart';
import 'package:health_sentry/app/features/accounts/widgets/account_table_widget.dart';

class AccountView extends ConsumerStatefulWidget {
  const AccountView({super.key});
  static const routeName = '/account';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView> {
  var isEditing = false;
  var delayDisabled = false;
  var editingText = "Edit";

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var usernameController = TextEditingController();
  var userFormKey = GlobalKey<FormState>();
  var createUserFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminAccountsStream =
        ref.watch(accountsStreamProvider(UserRoles.admin.index));
    final clientAccountsStream =
        ref.watch(accountsStreamProvider(UserRoles.client.index));
    final currentUserFuture = ref.watch(currentUserFutureProvider);

    return ScaffoldPage.scrollable(
        header: PageHeader(
          title: Row(
            children: [
              const Text('Account'),
              const SizedBox(width: 8),
              currentUserFuture.maybeWhen(
                data: (data) {
                  final text =
                      user.User.isAdmin(data!.role) ? "ADMIN" : "CLIENT";
                  return Text(
                    text,
                    style: const TextStyle(fontSize: 12),
                  );
                },
                orElse: () => const Text(''),
              )
            ],
          ),
          commandBar: CommandBar(
              mainAxisAlignment: MainAxisAlignment.end,
              primaryItems: [
                CommandBarButton(
                    icon: const Icon(FluentIcons.sign_out),
                    label: const Text('Sign out'),
                    onPressed: () async {
                      await ref.read(firebaseAuthProvider).signOut();
                    })
              ]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Align(
              alignment: Alignment.center,
              child: Wrap(children: [
                SizedBox(
                  width: 300,
                  height: 110,
                  child: Column(
                    children: [
                      Form(
                        key: userFormKey,
                        child: InfoLabel(
                          label: 'Username',
                          child: currentUserFuture.when(
                            data: (data) {
                              ref
                                  .read(accountsRepositoryProvider)
                                  .getUser(data!.userId)
                                  .then(
                                (value) {
                                  usernameController.text = value!.username;
                                },
                              );
                              return TextFormBox(
                                controller: usernameController,
                                readOnly: !isEditing,
                                validator: (value) {
                                  if (!isValidUsername(value!)) {
                                    return 'Invalid username length.';
                                  }
                                  return null;
                                },
                              );
                            },
                            error: (error, stackTrace) =>
                                const TextBox(readOnly: true),
                            loading: () => const TextBox(readOnly: true),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Button(
                              onPressed: delayDisabled
                                  ? null
                                  : () {
                                      setState(() {
                                        isEditing = !isEditing;
                                        if (isEditing) {
                                          editingText = "Cancel";
                                        } else {
                                          editingText = "Edit";
                                        }
                                      });
                                    },
                              child: Text(editingText)),
                          FilledButton(
                              onPressed: !isEditing
                                  ? null
                                  : () async {
                                      final isValid =
                                          userFormKey.currentState?.validate();
                                      if (isValid == null || !isValid) return;
                                      setState(() {
                                        isEditing = false;
                                        delayDisabled = true;
                                        editingText = "Edit";
                                      });
                                      final user =
                                          ref.read(currentUserStateProvider);
                                      ref
                                          .read(accountsRepositoryProvider)
                                          .updateUsername(user!.uid,
                                              usernameController.text);
                                      await Future.delayed(
                                          const Duration(seconds: 5));
                                      setState(() {
                                        delayDisabled = false;
                                      });
                                    },
                              child: const Text('Save')),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 900,
                  height: 500,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Admins',
                            style: FluentTheme.of(context).typography.subtitle,
                          ),
                          currentUserFuture.when(
                            data: (data) {
                              var res = (data != null) &&
                                  (user.User.isAdmin(data.role));
                              if (res) {
                                return FilledButton(
                                    onPressed: () {
                                      showCreateUserContentDialog(context,
                                          (user) {
                                        ref
                                            .read(accountsRepositoryProvider)
                                            .addUser(user)
                                            .then((value) {
                                          firstNameController.clear();
                                          lastNameController.clear();
                                          passwordController.clear();
                                          emailController.clear();
                                        });
                                      }, role: user.UserRoles.admin);
                                    },
                                    child: const Text("NEW"));
                              }
                              return const FilledButton(
                                onPressed: null,
                                child: Text('NEW'),
                              );
                            },
                            error: (error, stackTrace) {
                              return const FilledButton(
                                onPressed: null,
                                child: Text('NEW'),
                              );
                            },
                            loading: () => const ProgressRing(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 450,
                        width: 900,
                        child: adminAccountsStream.when(
                          data: (data) {
                            final accounts =
                                data.docs.map((e) => e.data()).toList();
                            return AccountPaginatedDataTableWidget(
                                data: accounts);
                          },
                          error: (error, stackTrace) {
                            return ColoredBox(color: Colors.red);
                          },
                          loading: () => const ProgressBar(),
                        ),
                      )
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 900,
                  height: 500,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Clients',
                            style: FluentTheme.of(context).typography.subtitle,
                          ),
                          currentUserFuture.when(
                            data: (data) {
                              if (data != null &&
                                  (user.User.isAdmin(data.role))) {
                                return FilledButton(
                                    onPressed: () {
                                      showCreateUserContentDialog(context,
                                          (user) {
                                        ref
                                            .read(accountsRepositoryProvider)
                                            .addUser(user)
                                            .then((value) {
                                          firstNameController.clear();
                                          lastNameController.clear();
                                          passwordController.clear();
                                          emailController.clear();
                                        });
                                      }, role: user.UserRoles.client);
                                    },
                                    child: const Text("NEW"));
                              }
                              return const FilledButton(
                                onPressed: null,
                                child: Text('NEW'),
                              );
                            },
                            error: (error, stackTrace) => const FilledButton(
                              onPressed: null,
                              child: Text('NEW'),
                            ),
                            loading: () => const ProgressRing(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 450,
                        width: 900,
                        child: clientAccountsStream.when(
                          data: (data) {
                            final accounts =
                                data.docs.map((e) => e.data()).toList();
                            return AccountPaginatedDataTableWidget(
                                data: accounts);
                          },
                          error: (error, stackTrace) {
                            return ColoredBox(color: Colors.red);
                          },
                          loading: () => const ProgressBar(),
                        ),
                      )
                    ],
                  )),
            ],
          )
        ]);
  }

  void showCreateUserContentDialog(
      BuildContext context, void Function(user.User user) callback,
      {user.UserRoles role = user.UserRoles.client}) async {
    var selectedBarangay = LocalData.barangays.first;
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text('New ${role.name}'),
        content: StatefulBuilder(
          builder: (context, StateSetter setState) {
            return SingleChildScrollView(
              child: Form(
                key: createUserFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoLabel(
                      label: 'First name',
                      child: TextFormBox(
                        controller: firstNameController,
                        validator: (value) {
                          if (!isValidLength(value ?? '')) {
                            return "Invalid first name";
                          }
                          return null;
                        },
                      ),
                    ),
                    InfoLabel(
                      label: 'Last name',
                      child: TextFormBox(
                        controller: lastNameController,
                        validator: (value) {
                          if (!isValidLength(value ?? '')) {
                            return "Invalid last name";
                          }
                          return null;
                        },
                      ),
                    ),
                    InfoLabel(
                      label: 'Email',
                      child: TextFormBox(
                        controller: emailController,
                        validator: (value) {
                          if (!isValidEmail(value ?? '')) {
                            return "Invalid email format";
                          }
                          return null;
                        },
                      ),
                    ),
                    InfoLabel(
                      label: 'Password',
                      child: TextFormBox(
                        controller: passwordController,
                        validator: (value) {
                          if (!isPasswordValid(value ?? '')) {
                            return "Invalid password length";
                          }
                          return null;
                        },
                      ),
                    ),
                    InfoLabel(
                      label: 'Barangay',
                      child: AutoSuggestBox<String>(
                        placeholder: selectedBarangay.toUpperCase(),
                        onChanged: (text, reason) => setState(
                            () => selectedBarangay = text.toUpperCase()),
                        onSelected: (barangay) =>
                            setState(() => selectedBarangay = barangay.value!),
                        items: LocalData.barangays.map(
                          (barangay) {
                            return AutoSuggestBoxItem<String>(
                              value: barangay,
                              label: barangay.toUpperCase(),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, 'cancel');
              // Delete file here
            },
          ),
          FilledButton(
            child: const Text('Done'),
            onPressed: () async {
              if (!mounted) return;
              final isValid = createUserFormKey.currentState?.validate();
              if (isValid != null && isValid) {
                final firstname = firstNameController.text;
                final lastname = lastNameController.text;
                final email = emailController.text;
                final password = passwordController.text;
                try {
                  final newUserApp = await Firebase.initializeApp(
                      name: 'newUser',
                      options: DefaultFirebaseOptions.currentPlatform);

                  final newUserInstance =
                      FirebaseAuth.instanceFor(app: newUserApp);
                  final userCredential =
                      await newUserInstance.createUserWithEmailAndPassword(
                          email: email, password: password);
                  await newUserInstance.signOut();
                  await newUserApp.delete();
                  // final credentials = await FirebaseAuth.instance
                  //     .createUserWithEmailAndPassword(
                  //         email: email, password: password);
                  callback(
                    user.User(
                        timestamp: DateTime.now(),
                        username: "$lastname, ${firstname[0]}",
                        firstname: firstname,
                        lastname: lastname,
                        userId: userCredential.user!.uid,
                        email: email,
                        barangay: selectedBarangay,
                        role: role.index),
                  );
                } on FirebaseAuthException catch (e) {
                  await displayInfoBar(context, builder: (context, close) {
                    return InfoBar(
                      title: const Text('Error'),
                      content: Text(e.message!),
                      action: IconButton(
                        icon: const Icon(FluentIcons.clear),
                        onPressed: close,
                      ),
                      severity: InfoBarSeverity.error,
                    );
                  });
                }

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
    setState(() {});
  }
}
