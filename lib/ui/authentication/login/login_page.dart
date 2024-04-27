import 'package:flutter/material.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';
import 'package:provider/provider.dart';
import 'login_view_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(authProvider),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) => Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: viewModel.isLoading
                  ? null
                  : IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil("/introduction", (route) => false);
                        Navigator.pushReplacementNamed(context, "/introduction");
                        },
                    ),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Login Akun",
                              style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10.0),
                          const Text("masuk akun yang sudah terdaftar"),
                          const SizedBox(height: 40.0),
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
                          const SizedBox(height: 40.0),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async{
                                await viewModel.login(
                                    context,
                                    _emailController.text.trim(),
                                    _passwordController.text.trim());
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
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
                          const SizedBox(height: 50.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Tidak memiliki akun?",
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 5.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/register/consumer');
                                },
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(
                                      color: Color(0xFF8AAB97),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
              ],
            )),
      ),
    );
  }
}
