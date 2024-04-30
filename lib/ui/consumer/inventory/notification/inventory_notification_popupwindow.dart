
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'inventory_notification_popupwindow_view_model.dart';

class InventoryNotificationPopUpWindow extends StatefulWidget {
  const InventoryNotificationPopUpWindow({super.key});

  @override
  State<InventoryNotificationPopUpWindow> createState() => _InventoryNotificationPopUpWindowState();
}

class _InventoryNotificationPopUpWindowState extends State<InventoryNotificationPopUpWindow> {
  int _selectedValue=0;

  @override
  void initState() {
    super.initState();
    _loadNotificationDuration();
  }

  Future<void> _loadNotificationDuration() async {
    final viewModel =
    Provider.of<InventoryNotificationPopUpWindowViewModel>(
        context,
        listen: false);
    int duration = await viewModel.getNotificationDuration();
    setState(() {
      _selectedValue = duration;
    });
  }
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryNotificationPopUpWindowViewModel>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Notifikasi",style: Theme.of(context).textTheme.headlineSmall!),
              ),
            ),
            RadioListTile(
              title: const Text('Satu Minggu'),
              value: 7,
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  _selectedValue = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('Dua Minggu'),
              value: 14,
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  _selectedValue = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('Satu Bulan'),
              value: 30,
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  _selectedValue = value!;
                });
              },
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async{
                  await viewModel.addDuration(_selectedValue);
                  Navigator.of(context).pushNamedAndRemoveUntil("/consumer", (route) => false);
                },
                style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(
                        const Color(0xFF7A779E)),
                    shape: MaterialStateProperty.all<
                        RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.0),
                      ),
                    )),
                child: Text('Save',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
