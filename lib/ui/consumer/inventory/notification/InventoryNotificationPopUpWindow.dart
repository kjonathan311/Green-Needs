
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InventoryNotificationPopUpWindow extends StatefulWidget {
  const InventoryNotificationPopUpWindow({super.key});

  @override
  State<InventoryNotificationPopUpWindow> createState() => _InventoryNotificationPopUpWindowState();
}

class _InventoryNotificationPopUpWindowState extends State<InventoryNotificationPopUpWindow> {
  int _selectedValue=1;

  @override
  Widget build(BuildContext context) {
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
              value: 1,
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  _selectedValue = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('Dua Minggu'),
              value: 2,
              groupValue: _selectedValue,
              onChanged: (value) {
                setState(() {
                  _selectedValue = value!;
                });
              },
            ),
            RadioListTile(
              title: const Text('Satu Bulan'),
              value: 3,
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
                onPressed: () {},
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
