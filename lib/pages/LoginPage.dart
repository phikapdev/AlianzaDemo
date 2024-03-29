import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_alianzademo/services/auth.dart';
import 'package:app_alianzademo/services/notifications.dart';
import 'package:app_alianzademo/providers/loginProvider.dart';
import 'package:app_alianzademo/ui/input_decorations.dart';

class LoginPage extends StatelessWidget {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, false);
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
                leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 20.0,
              onPressed: () {
                Navigator.pop(context, false);
              },
            )),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Image.asset(
                            'asset/images/ic_coin_login.png',
                            width: 150.0,
                            height: 150.0,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),
                          //Text('Iniciar', style: Theme.of(context).textTheme.headline4 ),
                          Text(
                              'Inicia sesion para continuar, Ingresa tu Correo Electronico',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                          SizedBox(height: 30),

                          ChangeNotifierProvider(
                              create: (_) => loginProvider(),
                              child: _LoginForm())
                        ],
                      )),
                ],
              ),
            )));
  }
}

class _LoginForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<loginProvider>(context);

    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                  hintText: '',
                  labelText: 'Correo Electronico',
                  prefixIcon: Icons.email),
              onChanged: (value) => loginForm.email = value,
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp = new RegExp(pattern);

                return regExp.hasMatch(value ?? '')
                    ? null
                    : 'Incorrecto el Formato del Correo';
              },
            ),
            SizedBox(height: 30),
            TextFormField(
              controller: passwordController,
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: InputDecorations.authInputDecoration(
                  hintText: '*****',
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock_outline),
              onChanged: (value) => loginForm.password = value,
              validator: (value) {
                return (value != null && value.length >= 6)
                    ? null
                    : 'La contraseña debe ser de mas de 6 caracteres';
              },
            ),
            SizedBox(height: 20),
            MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.blueAccent,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    child: Text(
                      loginForm.isLoading ? 'Cargando...' : 'Ingresar',
                      style: TextStyle(color: Colors.white),
                    )),
                onPressed: loginForm.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          loginForm.isLoading = true;

                          FocusScope.of(context).unfocus();
                          final auth =
                              Provider.of<Auth>(context, listen: false);

                          final String? message = await auth.login(
                              loginForm.email, loginForm.password);

                          if (message == null) {
                            Navigator.pushReplacementNamed(context, 'home');
                          } else {
                            Notifications.showSnackbar(message);
                            loginForm.isLoading = false;
                          }
                        }
                      })
          ],
        ),
      ),
    );
  }
}
