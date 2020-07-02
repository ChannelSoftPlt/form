import 'dart:convert';

import 'package:my/object/merchant.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/product.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://www.petkeeper.com.my/form/';

  static var registration = domain + 'registration/index.php';
  static var order = domain + 'mobile_api/order/index.php';
  static var product = domain + 'mobile_api/product/index.php';
  static var orderItem = domain + 'mobile_api/order_detail/index.php';
  static var postcode = domain + 'mobile_api/postcode/index.php';

  static var whatsAppLink = domain + 'order/view-order.php/';

  fetchOrder(currentPage, itemPerPage, orderStatus, query) async {
    var response = await http.post(Domain.order, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'start_date': '2020-05-01',
      'end_date': '2020-06-30',
      'query': query,
      'order_status': orderStatus,
      'page': currentPage.toString(),
      'itemPerPage': itemPerPage.toString()
    });
    return jsonDecode(response.body);
  }

  /*
  * read order detail
  * */
  fetchOrderDetail(publicUrl, orderId) async {
    var response = await http.post(Domain.order, body: {
      'read_order_detail': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'public_url': publicUrl,
      'order_id': orderId
    });
    return jsonDecode(response.body);
  }

  /*
  * read product
  * */
  fetchProduct(formId) async {
    var response = await http.post(Domain.product, body: {
      'read': '1',
      'form_id': formId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read postcode, city, state
  * */
  fetchPostcodeDetails(postcode) async {
    var response = await http.post(Domain.postcode, body: {
      'read': '1',
      'postcode': postcode,
    });
    return jsonDecode(response.body);
  }

  /*
  * update status
  * */
  updateStatus(status, orderId) async {
    var response = await http.post(Domain.order, body: {
      'update_order_status': '1',
      'order_id': orderId,
      'status': status
    });
    return jsonDecode(response.body);
  }

  /*
  * update order item
  * */
  updateOrderItem(OrderItem object) async {
    var response = await http.post(Domain.orderItem, body: {
      'update': '1',
      'status': object.status,
      'price': object.price,
      'quantity': object.quantity,
      'order_product_id': object.orderProductId.toString(),
    });
    return jsonDecode(response.body);
  }

  /*
  * update order address && postcode
  * */
  updateAddress(Order object) async {
    var response = await http.post(Domain.order, body: {
      'update_address': '1',
      'postcode': object.postcode,
      'address': object.address,
      'order_id': object.id.toString(),
    });
    return jsonDecode(response.body);
  }

  /*
  * update order delivery and tax
  * */
  updateShippingFeeAndTax(Order object) async {
    print('delivery: ' + object.deliveryFee);
    print('tax: ' + object.tax);
    var response = await http.post(Domain.orderItem, body: {
      'update': '1',
      'delivery_fee': object.deliveryFee,
      'tax': object.tax,
      'order_id': object.id.toString(),
    });
    return jsonDecode(response.body);
  }

  /*
  * update password
  * */
  updatePassword(String currentPassword, String newPassword) async {
    var response = await http.post(Domain.registration, body: {
      'update': '1',
      'current_password': currentPassword,
      'new_password': newPassword,
      'merchant_id':
      Merchant.fromJson(await SharePreferences().read("merchant"))
          .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update order delivery and tax
  * */
  addOrderItem(Product object, orderId, quantity) async {
    print('status: ' + object.status.toString());
    print('order_id: ' + object.productId.toString());
    print('price: ' + object.price);
    print('quantity: ' + quantity);
    print('description: ' + object.description);
    print('name: ' + object.name);

    var response = await http.post(Domain.orderItem, body: {
      'create': '1',
      'status': object.status.toString(),
      'order_id': orderId,
      'product_id': object.productId.toString(),
      'price': object.price,
      'quantity': quantity,
      'description': object.description,
      'name': object.name,
    });
    return jsonDecode(response.body);
  }
}
