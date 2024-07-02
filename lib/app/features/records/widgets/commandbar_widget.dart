import 'package:fluent_ui/fluent_ui.dart';

class CommandBarWidget extends StatelessWidget {
  const CommandBarWidget(
      {super.key, required this.newContentDialog, required this.exportData});

  final void Function() newContentDialog;
  final void Function() exportData;

  @override
  Widget build(BuildContext context) {
    return CommandBar(
      mainAxisAlignment: MainAxisAlignment.end,
      primaryItems: [
        CommandBarButton(
          icon: const Icon(FluentIcons.add),
          label: const Text("NEW"),
          onPressed: () {
            newContentDialog();
          },
        ),
        // CommandBarButton(
        //     icon: const Icon(FluentIcons.import),
        //     label: const Text("IMPORT"),
        //     onPressed: () async {}),
        CommandBarButton(
            icon: const Icon(FluentIcons.excel_document),
            label: const Text("EXPORT"),
            onPressed: () {
              exportData();
            })
      ],
    );
  }
}
