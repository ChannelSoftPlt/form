import 'dart:convert';

import 'package:my/object/merchant.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/product.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://www.emenu.com.my/';

  static var registration = domain + 'registration/index.php';
  static var order = domain + 'mobile_api/order/index.php';
  static var product = domain + 'mobile_api/product/index.php';
  static var orderItem = domain + 'mobile_api/order_detail/index.php';
  static var postcode = domain + 'mobile_api/postcode/index.php';
  static var orderGroup = domain + 'mobile_api/order_group/index.php';
  static var driver = domain + 'mobile_api/driver/index.php';
  static var profile = domain + 'profile/index.php';
  static var user = domain + 'mobile_api/user/index.php';

  static var whatsAppLink = domain + 'order/view-order.php';

  fetchOrder(currentPage, itemPerPage, orderStatus, query, orderGroupId,
      driverId, startDate, endDate) async {
    var response = await http.post(Domain.order, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'start_date': startDate,
      'end_date': endDate,
      'driver_id': driverId,
      'query': query,
      'order_group_id': orderGroupId.toString(),
      'order_status': orderStatus,
      'page': currentPage.toString(),
      'itemPerPage': itemPerPage.toString()
    });
    return jsonDecode(response.body);
  }

  fetchGroupWithPagination(
      currentPage, itemPerPage, query, startDate, endDate) async {
    var response = await http.post(Domain.orderGroup, body: {
      'read_with_pagination': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'start_date': startDate,
      'end_date': endDate,
      'query': query,
      'page': currentPage.toString(),
      'itemPerPage': itemPerPage.toString()
    });
    return jsonDecode(response.body);
  }

  fetchGroupDetail(orderGroupId) async {
    var response = await http.post(Domain.orderGroup,
        body: {'read_total': '1', 'order_group_id': orderGroupId.toString()});
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
  * read group
  * */
  fetchGroup() async {
    var response = await http.post(Domain.orderGroup, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read driver
  * */
  fetchDriver() async {
    var response = await http.post(Domain.driver, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read profile
  * */
  fetchProfile() async {
    var response = await http.post(Domain.profile, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read user list
  * */
  fetchUser(currentPage, itemPerPage, query) async {
    var response = await http.post(Domain.user, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'query': query,
      'page': currentPage.toString(),
      'itemPerPage': itemPerPage.toString()
    });
    return jsonDecode(response.body);
  }

  /*
  * read product
  * */
  launchCheck() async {
    var response = await http.post(Domain.registration, body: {
      'launch_check': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
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
  * update status
  * */
  updateMultipleStatus(status, orderIds) async {
    print(orderIds);
    var response = await http.post(Domain.order, body: {
      'update_order_status': '1',
      'order_ids': orderIds,
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
  * update profile
  * */
  updateProfile(
      companyName, companyAddress, contactNumber, personInCharge) async {
    var response = await http.post(Domain.profile, body: {
      'update': '1',
      'address': companyAddress,
      'phone': contactNumber,
      'name': personInCharge,
      'company_name': companyName,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update profile
  * */
  updatePayment(bankDetail, bankTransfer, cod) async {
    var response = await http.post(Domain.profile, body: {
      'update': '1',
      'bank_details': bankDetail,
      'cash_on_delivery': cod,
      'bank_transfer': bankTransfer,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * add order item
  * */
  addOrderItem(Product object, orderId, quantity, remark) async {
    var response = await http.post(Domain.orderItem, body: {
      'create': '1',
      'status': object.status.toString(),
      'order_id': orderId,
      'product_id': object.productId.toString(),
      'price': object.price,
      'quantity': quantity,
      'description': object.description,
      'name': object.name,
      'remark': remark,
    });
    return jsonDecode(response.body);
  }

  /*
  * assign order group
  * */
  setOrderGroup(status, groupName, orderId, orderGroupId) async {
    print('status: $status');
    print('groupName: $groupName');
    print('orderId: $orderId');
    print('orderGroupId: $orderGroupId');

    var response = await http.post(Domain.orderGroup, body: {
      'action': orderGroupId == '' ? 'create' : 'update',
      'status': status,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'group_name': groupName,
      'order_id': orderId,
      'order_group_id': orderGroupId,
    });
    return jsonDecode(response.body);
  }

  /*
  * assign driver
  * */
  setDriver(driverName, orderId, driverId) async {
    print('driverName: $driverName');
    print('orderId: $orderId');
    print('driverId: $driverId');

    var response = await http.post(Domain.driver, body: {
      'action': driverId == '' ? 'create' : 'update',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'driver_name': driverName,
      'order_id': orderId,
      'driver_id': driverId,
    });
    return jsonDecode(response.body);
  }

  /*
  * forgot password send pac
  * */
  sendPac(email, pac) async {
    var response = await http.post(Domain.registration, body: {
      'forgot_password': '1',
      'email': email,
      'pac': pac,
    });
    return jsonDecode(response.body);
  }

  /*
  * forgot password update password
  * */
  setNewPassword(newPassword, email) async {
    var response = await http.post(Domain.registration, body: {
      'forgot_password': '1',
      'new_password': newPassword,
      'email': email,
    });
    return jsonDecode(response.body);
  }

  /*--------------------------------------------------------------------delete part-------------------------------------------------------------------------------*/
  /*
  * delete order item
  * */
  deleteOrderItem(orderProductId) async {
    var response = await http.post(Domain.orderItem, body: {
      'delete': '1',
      'order_product_id': orderProductId,
    });
    return jsonDecode(response.body);
  }
}
