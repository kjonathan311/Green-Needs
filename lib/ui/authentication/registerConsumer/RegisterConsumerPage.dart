import 'package:flutter/material.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';
import 'package:greenneeds/ui/authentication/registerConsumer/RegisterConsumerViewModel.dart';
import 'package:provider/provider.dart';


class RegisterConsumerPage extends StatefulWidget {
  const RegisterConsumerPage({super.key});

  @override
  State<RegisterConsumerPage> createState() => _RegisterConsumerPageState();
}

class _RegisterConsumerPageState extends State<RegisterConsumerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    return ChangeNotifierProvider(
      create: (context) => RegisterConsumerViewModel(authProvider),
      child: Consumer<RegisterConsumerViewModel>(
        builder: (context, viewModel, _) => Center(
          child: Scaffold(
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Register Akun",
                            style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10.0),
                        const Text("buat akun baru"),
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
                        const SizedBox(height: 40.0),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              viewModel.registerConsumer(
                                  context,
                                  _nameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  _phoneNumberController.text.trim());
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xFF7A779E)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                )),
                            child: Text('Register',
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 50.0),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Ingin menjual food waste?",
                                  style: TextStyle(fontSize: 16)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/register/foodprovider');
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
                if (viewModel.isLoading)
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
      ),
    );
  }
}
