import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/MainSettings.dart';
import 'package:greenneeds/ui/admin/settings/settings_view_model.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan Global"),
        actions: [
          IconButton(onPressed: ()async{
            await settingsViewModel.editMainSettings(context, _costController.text.trim(), _taxController.text.trim());
          }, icon: Icon(Icons.edit))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(32),
                child: FutureBuilder(
                    future: settingsViewModel.fetchSettings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        MainSettings? settings = snapshot.data;
                        _costController.text = settings!.costPerKm;
                        _taxController.text = settings.tax;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
                            Text("biaya admin",style: Theme.of(context).textTheme.bodyLarge),
                            SizedBox(height: 5.0),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _taxController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                Container(
                                  padding:EdgeInsets.symmetric(horizontal: 20),
                                  child: Text("%",style: TextStyle(fontSize: 20)),
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Text("biaya per km",style: Theme.of(context).textTheme.bodyLarge),
                            SizedBox(height: 5.0),
                            TextField(
                              controller: _costController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        );
                      }else if(snapshot.hasError){
                      return Center(child: Text("${snapshot.error}"));
                      }else{
                        return const Center(child: Text('Error fetching settings'));
                      }
                    })
                ),
          )
        ],
      ),
    );
  }
}
