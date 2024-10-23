import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String content;
  final VoidCallback onPrimaryConfirm;
  final VoidCallback onCancel;
  final String primaryConfirmText;
  final String cancelText;
  final IconData? icon;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final bool showCheckbox;
  final String checkboxText;
  final String? secondConfirmText;
  final VoidCallback? onSecondConfirm;
  final Color? secondConfirmButtonColor;
  final bool? centerText;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onPrimaryConfirm,
    required this.onCancel,
    this.primaryConfirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.icon,
    this.centerText = false,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.showCheckbox = false,
    this.checkboxText = 'Remember my choice',
    this.secondConfirmText,
    this.onSecondConfirm,
    this.secondConfirmButtonColor = Colors.white,
  });

  @override
  _ConfirmationDialogState createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //actionsAlignment: MainAxisAlignment.spaceEvenly,
      
      insetPadding: EdgeInsets.all(20),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) Icon(widget.icon),
          if (widget.icon != null) SizedBox(height: 8),
          Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.content, style: TextStyle(color: Colors.white)),
          if (widget.showCheckbox)
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                Text(widget.checkboxText),
              ],
            ),
        ],
      ),
      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            
            children: [
             TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              // Text color
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor, // Background color
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0), // Padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
            ),
            child: Text(widget.cancelText, style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              widget.onPrimaryConfirm();
              if (widget.showCheckbox) {
                // Handle the checkbox state if needed
                print('Checkbox is ${_isChecked ? 'checked' : 'unchecked'}');
              }
              if (context.mounted && Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
            },
            style: TextButton.styleFrom(
              backgroundColor: widget.confirmButtonColor ??
                  Theme.of(context).scaffoldBackgroundColor, // Background color
              // Text color
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0), // Padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
            ),
            child: Text(
              widget.primaryConfirmText,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          if (widget.onSecondConfirm != null && widget.secondConfirmText != null)
            TextButton(
              onPressed: () {
                widget.onSecondConfirm!();
                if (context.mounted && Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
                
              },
              style: TextButton.styleFrom(
                // Text color
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor, // Background color
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0), // Padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
              child: Text(widget.secondConfirmText!,
                  style: TextStyle(
                      color: widget.secondConfirmButtonColor ??
                          Theme.of(context).primaryColor),
                  softWrap: true,
                          ),
                  
            )
          ],),
        )
       
      ],
    );
  }
}
