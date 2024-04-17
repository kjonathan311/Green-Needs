import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';
import 'package:provider/provider.dart';

import 'introduction_view_model.dart';

class IntroductionPage extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    final viewModel = IntroductionPageViewModel(authProvider);

    viewModel.handleInitialRoute(context);

    return ChangeNotifierProvider<IntroductionPageViewModel>(
        create: (context)=>viewModel,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/introduction_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: FractionallySizedBox(
                    widthFactor: 1.0,
                    heightFactor: 0.7,
                    child: Container(
                      color: Colors.white.withOpacity(0.8),
                      padding: EdgeInsets.all(32.0),
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Selamat Datang di Green Needs",
                                style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
                            const SizedBox(height: 10.0),
                            const Text("Solusi Cerdas untuk Masalah Food Waste!"),
                            const SizedBox(height: 40.0),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (){
                                  Navigator.pushNamed(context, "/login");
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        const Color(0xFF7A779E)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Adjust the radius as needed
                                      ),
                                    )),
                                child: Text('Login',
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (){
                                  Navigator.pushNamed(context, "/register/consumer");
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        const Color(0xFF8AAB97)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Adjust the radius as needed
                                      ),
                                    )),
                                child: Text('Register',
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (){
                                  Navigator.pushNamed(context, "/register/foodprovider");
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        const Color(0xFFD98D62)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0), // Adjust the radius as needed
                                      ),
                                    )),
                                child: Text('Register Penyedia Makanan',
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20)),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (viewModel.isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ),
      ),
    );


  }
}


