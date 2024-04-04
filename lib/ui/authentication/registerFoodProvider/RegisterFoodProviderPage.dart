import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';
import 'package:provider/provider.dart';

import 'RegisterFoodProviderViewModel.dart';

class RegisterFoodProviderPage extends StatefulWidget {
  const RegisterFoodProviderPage({super.key});

  @override
  State<RegisterFoodProviderPage> createState() => _RegisterFoodProviderPageState();
}

class _RegisterFoodProviderPageState extends State<RegisterFoodProviderPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  bool _obscureText = true;



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    return ChangeNotifierProvider(
        create: (context)=>RegisterFoodProviderViewModel(authProvider),
      child: Consumer<RegisterFoodProviderViewModel>(
        builder: (context,viewModel,_)=>
            Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: viewModel.isLoading ? null: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: (){
                Navigator.of(context).pushNamedAndRemoveUntil("/introduction", (route) => false);
                Navigator.pushReplacementNamed(context, "/introduction");
                },
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Register Akun Penyedia Makanan",
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10.0),
                      const Text("buat akun baru untuk menjual food waste"),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: "Nama",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          hintText: "Nomor HP",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20.0),

                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: "alamat",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          hintText: "kota",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (){
                            viewModel.registerFoodProvider(
                                context,
                                _nameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                _phoneNumberController.text.trim(),
                                _addressController.text.trim(),
                                _cityController.text.trim()
                            );
                          },
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all<Color>(const Color(0xFF7A779E)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              )),
                          child:
                          Text('Register',
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Ingin membuat akun dasar?", style: TextStyle(fontSize: 16)),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register/consumer');
                              },
                              child: const Text("Sign up disini",
                                  style: TextStyle(
                                      color: Color(0xFF8AAB97),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if(viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }


}


