import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
import 'common.dart';
import 'main.dart';

class TrackPurchaseData extends StatefulWidget {
  @override
  TrackPurchaseDataState createState() => new TrackPurchaseDataState();
}

class TrackPurchaseDataState extends State<TrackPurchaseData> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _endDateController = TextEditingController();

  String? productId;
  int productType = 0;
  String? productTitle;
  double? price;
  String? priceCurrency;
  DateTime? purchaseDate;
  String? purchaseId;
  List<bool> productTypeSelection = [true, false];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    buildContextList.add(context);
    return Form(
        key: _formKey,
        child: new ListView(
            padding: const EdgeInsets.all(10), children: getFormWidget()));
  }

  List<Widget> getFormWidget() {
    List<Widget> formWidget = List.empty(growable: true);
    formWidget.add(new Container(
        child: new TextButton(
          onPressed: () {
            buildContextList.removeLast();
            Navigator.pop(context, {'reload': true});
          },
          child: new Text('< Back'),
          style: TextButton.styleFrom(
              backgroundColor: Colors.blue, primary: Colors.white),
        ),
        decoration: new BoxDecoration(
            color: Colors.white,
            border: new Border(bottom: new BorderSide()))));

    formWidget.add(new TextFormField(
        decoration: InputDecoration(labelText: 'Product ID', hintText: 'ID'),
        onChanged: (value) => setState(() {
              productId = value;
            })));

    formWidget.add(
        Text('Product type', style: TextStyle(fontWeight: FontWeight.bold)));
    formWidget.add(new ToggleButtons(
      children: [
        Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
      onPressed: (index) => setState(() {
        for (int buttonIndex = 0;
            buttonIndex < this.productTypeSelection.length;
            buttonIndex++) {
          if (buttonIndex == index) {
            this.productTypeSelection[buttonIndex] = true;
          } else {
            this.productTypeSelection[buttonIndex] = false;
          }
        }
        this.productType = index;
      }),
      isSelected: productTypeSelection,
    ));

    formWidget.add(new TextFormField(
        decoration:
            InputDecoration(labelText: 'Product Title', hintText: 'Title'),
        onChanged: (value) => setState(() {
              productTitle = value;
            })));

    formWidget.add(new TextFormField(
        decoration: InputDecoration(labelText: 'Price', hintText: 'Price'),
        onChanged: (value) => setState(() {
              price = double.parse(value);
            }),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[0-9.,]+')),
        ]));

    formWidget.add(new TextFormField(
        decoration:
            InputDecoration(labelText: 'Currency', hintText: 'Currency'),
        onChanged: (value) => setState(() {
              priceCurrency = value;
            }),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
        ]));

    formWidget.add(new TextFormField(
        controller: _endDateController,
        enabled: false,
        decoration:
            InputDecoration(labelText: 'Purchase date', hintText: 'Date')));

    formWidget.add(TextButton(
        onPressed: () {
          DatePicker.showDatePicker(context, showTitleActions: true,
              onConfirm: (date) {
            this.setState(() {
              purchaseDate = date;
              var year = date.year;
              var month = date.month;
              var day = date.day;
              _endDateController.text = '$year/$month/$day';
            });
          }, currentTime: DateTime.now(), locale: LocaleType.en);
        },
        child: Text(
          'Date Picker',
          style: TextStyle(color: Colors.blue),
        )));

    formWidget.add(new TextFormField(
        decoration:
            InputDecoration(labelText: 'Purchase ID', hintText: 'Purchase ID'),
        onChanged: (value) => setState(() {
              purchaseId = value;
            })));

    formWidget.add(new ElevatedButton(
        onPressed: executePost,
        style: ElevatedButton.styleFrom(
            primary: Colors.blue, onPrimary: Colors.white),
        child: Text('Send')));

    return formWidget;
  }

  executePost() async {
    if (productId == null || productId!.isEmpty) {
      showAlert(context, 'Error', 'ProductId cannot be null or empty');
      return;
    }
    if (productTitle == null || productTitle!.isEmpty) {
      showAlert(context, 'Error', 'ProductTitle cannot be null or empty');
      return;
    }
    if (price == null) {
      showAlert(context, 'Error', 'Price cannot be null or empty');
      return;
    }
    if (priceCurrency == null || priceCurrency!.isEmpty) {
      showAlert(context, 'Error', 'PriceCurrency cannot be null or empty');
      return;
    }
    if (purchaseDate == null) {
      showAlert(context, 'Error', 'PurchaseDate cannot be null or empty');
      return;
    }
    if (purchaseId == null || purchaseId!.isEmpty) {
      showAlert(context, 'Error', 'PurchaseId cannot be null or empty');
      return;
    }
    ProductType type =
        productType == 0 ? ProductType.item : ProductType.subscription;
    int date = (purchaseDate!.millisecondsSinceEpoch / 1000).floor();
    PurchaseData pData = PurchaseData(productId!, type, productTitle!, price!,
        priceCurrency!, date, purchaseId!);
    Analytics.trackPurchaseEvent(pData).then((result) {
      _formKey.currentState?.reset();
      _endDateController.clear();
      showAlert(context, 'Success', 'Purchase tracked: $result');
    }).catchError((error) {
      showError(context, error.toString());
    });
  }
}
