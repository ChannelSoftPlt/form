import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/object/merchant.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/snack_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class EditProfile extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<EditProfile> {
  var companyName = TextEditingController();
  var companyAddress = TextEditingController();
  var contactNumber = TextEditingController();
  var personInCharge = TextEditingController();
  var email = TextEditingController();
  var whatsAppNumber = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          '${AppLocalizations.of(context).translate('company_info')}',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.orangeAccent),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: Domain().fetchProfile(),
          builder: (context, object) {
            if (object.hasData) {
              if (object.connectionState == ConnectionState.done) {
                Map data = object.data;
                if (data['status'] == '1') {
                  List responseJson = data['profile'];

                  Merchant merchant = responseJson
                      .map((jsonObject) => Merchant.fromJson(jsonObject))
                      .toList()[0];

                  companyName.text = merchant.companyName;
                  companyAddress.text = merchant.address;
                  contactNumber.text = merchant.phone;
                  personInCharge.text = merchant.name;
                  email.text = merchant.email;
                  whatsAppNumber.text = merchant.whatsAppNumber;

                  return mainContent(context);
                } else {
                  return CustomProgressBar();
                }
              }
            }
            return Center(child: CustomProgressBar());
          }),
    );
  }

  Widget mainContent(context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 35, 20, 35),
                  child: Column(
                    children: <Widget>[
                      Theme(
                        data: new ThemeData(
                          primaryColor: Colors.orange,
                        ),
                        child: TextField(
                            keyboardType: TextInputType.text,
                            controller: companyName,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.home),
                              labelText: '${AppLocalizations.of(context).translate('company')}',
                              labelStyle: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                              hintText: '${AppLocalizations.of(context).translate('company_hint')}',
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.teal)),
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Theme(
                        data: new ThemeData(
                          primaryColor: Colors.orange,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          controller: companyAddress,
                          textAlign: TextAlign.start,
                          minLines: 1,
                          maxLines: 5,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on),
                            labelText: '${AppLocalizations.of(context).translate('address')}',
                            labelStyle:
                                TextStyle(fontSize: 16, color: Colors.blueGrey),
                            hintText: '${AppLocalizations.of(context).translate('address_hint')}',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Theme(
                        data: new ThemeData(
                          primaryColor: Colors.orange,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          controller: contactNumber,
                          textAlign: TextAlign.start,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_android),
                            labelText: '${AppLocalizations.of(context).translate('contact_number')}',
                            labelStyle:
                                TextStyle(fontSize: 16, color: Colors.blueGrey),
                            hintText: '${AppLocalizations.of(context).translate('contact_number_hint')}',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Theme(
                        data: new ThemeData(
                          primaryColor: Colors.orange,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: personInCharge,
                          textAlign: TextAlign.start,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: '${AppLocalizations.of(context).translate('person_in_charge')}',
                            labelStyle:
                                TextStyle(fontSize: 16, color: Colors.blueGrey),
                            hintText: '',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Theme(
                        data: new ThemeData(
                          primaryColor: Colors.orange,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          controller: whatsAppNumber,
                          textAlign: TextAlign.start,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_android),
                            labelText: '${AppLocalizations.of(context).translate('whatsapp_number')}',
                            labelStyle:
                                TextStyle(fontSize: 16, color: Colors.blueGrey),
                            hintText: '${AppLocalizations.of(context).translate('contact_number_hint')}',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Theme(
                        data: new ThemeData(
                          primaryColor: Colors.orange,
                        ),
                        child: TextField(
                          enabled: false,
                          keyboardType: TextInputType.emailAddress,
                          controller: email,
                          textAlign: TextAlign.start,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: '${AppLocalizations.of(context).translate('email')}',
                            labelStyle:
                                TextStyle(fontSize: 16, color: Colors.blueGrey),
                            hintText: '',
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          ),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: RaisedButton(
                          elevation: 5,
                          onPressed: () => updateProfile(context),
                          child: Text(
                            '${AppLocalizations.of(context).translate('update_profile')}',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  updateProfile(context) async {
    if (companyName.text.length > 0 &&
        companyAddress.text.length > 0 &&
        contactNumber.text.length > 0 &&
        whatsAppNumber.text.length > 0 &&
        personInCharge.text.length > 0) {
      /*
        * update profile
        * */
      Map data = await Domain().updateProfile(companyName.text,
          companyAddress.text, contactNumber.text, personInCharge.text, whatsAppNumber.text);

      if (data['status'] == '1') {
        CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('update_success')}');
        /*
          * invalid password
          * */
      }
      /*
        * server error
        * */
      else
        CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('something_went_wrong')}');
    } else
      CustomSnackBar.show(context, '${AppLocalizations.of(context).translate('all_field_required')}');
  }
}
