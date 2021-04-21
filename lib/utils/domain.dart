import 'dart:convert';

import 'package:my/object/coupon.dart';
import 'package:my/object/form.dart';
import 'package:my/object/merchant.dart';
import 'package:my/object/order.dart';
import 'package:my/object/order_group.dart';
import 'package:my/object/order_item.dart';
import 'package:my/object/product.dart';
import 'package:my/object/shippingSetting/east_west.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

class Domain {
//  static var domain = 'https://www.emenu.com.my/';

  //testing server
  static var domain = 'https://emenumobile.lkmng.com/';
  static var webDomain = 'https://www.formtest.lkmng.com/';

  static var order = domain + 'mobile_api/order/index.php';
  static var product = domain + 'mobile_api/product/index.php';
  static var orderItem = domain + 'mobile_api/order_detail/index.php';
  static var postcode = domain + 'mobile_api/postcode/index.php';
  static var orderGroup = domain + 'mobile_api/order_group/index.php';
  static var driver = domain + 'mobile_api/driver/index.php';
  static var profile = domain + 'profile/index.php';
  static var user = domain + 'mobile_api/user/index.php';
  static var discount = domain + 'mobile_api/coupon/index.php';
  static var notification = domain + 'mobile_api/notification/index.php';
  static var category = domain + 'mobile_api/category/index.php';
  static var export = domain + 'mobile_api/export/index.php';
  static var form = domain + 'mobile_api/form/index.php';
  static var shipping = domain + 'mobile_api/shipping/index.php';
  /*
  * Web Domain
  *
  * */
  static var registration = webDomain + 'registration/index.php';
  static var whatsAppLink = webDomain + 'order/view-order.php';
  static var imagePath = webDomain + 'product/image/';
  static var proofImgPath = webDomain + 'order/proof_img/';

  fetchOrder(currentPage, itemPerPage, orderStatus, query, orderGroupId,
      driverId, startDate, endDate) async {
    //get version
    PackageInfo package = await PackageInfo.fromPlatform();

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
      'itemPerPage': itemPerPage.toString(),
      'version': package.version
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
    //get version
    PackageInfo package = await PackageInfo.fromPlatform();

    var response = await http.post(Domain.order, body: {
      'read_order_detail': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'public_url': publicUrl,
      'order_id': orderId,
      'version': package.version
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
  * read discount coupon list
  * */
  fetchDiscount(currentPage, itemPerPage, query) async {
    var response = await http.post(Domain.discount, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'form_id':
          Merchant.fromJson(await SharePreferences().read("merchant")).formId,
      'query': query,
      'page': currentPage.toString(),
      'itemPerPage': itemPerPage.toString()
    });
    return jsonDecode(response.body);
  }

  /*
  * read discount coupon details
  * */
  fetchDiscountDetail(id) async {
    var response = await http.post(Domain.discount, body: {
      'read': '1',
      'id': id,
    });
    return jsonDecode(response.body);
  }

  /*
  * read discount coupon details
  * */
  fetchDiscountByCode(code, phone) async {
    var response = await http.post(Domain.discount, body: {
      'read': '1',
      'coupon_code': code,
      'phone': phone,
      'form_id':
          Merchant.fromJson(await SharePreferences().read("merchant")).formId,
    });
    return jsonDecode(response.body);
  }

  fetchProductWithPagination(
      currentPage, itemPerPage, query, categoryName) async {
    var response = await http.post(Domain.product, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'query': query,
      'category_name': categoryName,
      'page': currentPage.toString(),
      'itemPerPage': itemPerPage.toString()
    });
    return jsonDecode(response.body);
  }

  fetchProductVariationWithPagination(currentPage, itemPerPage, query) async {
    var response = await http.post(Domain.product, body: {
      'read_variation': '1',
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
  * read category
  * */
  fetchCategory() async {
    var response = await http.post(Domain.category, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * export customer
  * */
  fetchExportCustomer($startDate, $endDate) async {
    print('haha');
    print($startDate);
    print($endDate);
    var response = await http.post(Domain.export, body: {
      'export_customer': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'start_date': $startDate,
      'end_date': $endDate
    });
    return jsonDecode(response.body);
  }

  /*
  * export product
  * */
  fetchExportProduct($startDate, $endDate) async {
    print($startDate);
    print($endDate);
    var response = await http.post(Domain.export, body: {
      'export_product': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'start_date': $startDate,
      'end_date': $endDate
    });
    return jsonDecode(response.body);
  }

  /*
  * update category sequence
  * */
  updateCategorySequence(sequence) async {
    var response = await http.post(Domain.category, body: {
      'update_sequence': '1',
      'sequence': sequence,
    });
    return jsonDecode(response.body);
  }

  /*
  * launch check
  * */
  launchCheck() async {
    print(Domain.registration);
    var response = await http.post(Domain.registration, body: {
      'launch_check': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * check subscription days left
  * */
  expiredChecking() async {
    var response = await http.post(Domain.registration, body: {
      'subscription_check': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read product
  * */
  readGalleryLimit() async {
    var response = await http.post(Domain.product, body: {
      'read_gallery_limit': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read form
  * */
  readFormSetting() async {
    var response = await http.post(Domain.form, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read shipping setting
  * */
  readShippingSetting() async {
    var response = await http.post(Domain.shipping, body: {
      'read': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read east west setting
  * */
  readEastWestSetting() async {
    var response = await http.post(Domain.shipping, body: {
      'read_east_west': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read distance
  * */
  readDistanceSetting() async {
    var response = await http.post(Domain.shipping, body: {
      'read_distance': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * read postcode
  * */
  readPostcodeSetting() async {
    var response = await http.post(Domain.shipping, body: {
      'read_postcode': '1',
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
  * update shipping status
  * */
  updateShippingStatus(status) async {
    var response = await http.post(Domain.shipping, body: {
      'update_status': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'status': status.toString()
    });
    return jsonDecode(response.body);
  }

  /*
  * update phone number
  * */
  updatePhone(phone, orderId) async {
    var response = await http.post(Domain.order,
        body: {'update_phone': '1', 'order_id': orderId, 'phone': phone});
    return jsonDecode(response.body);
  }

  /*
  * update payment status
  * */
  updatePaymentStatus(paymentStatus, orderId) async {
    var response = await http.post(Domain.order, body: {
      'update_payment_status': '1',
      'order_id': orderId,
      'payment_status': paymentStatus
    });
    return jsonDecode(response.body);
  }

  /*
  * update remark
  * */
  updateCustomerNote(note, orderId) async {
    var response = await http.post(Domain.orderItem,
        body: {'update': '1', 'order_id': orderId, 'note': note});
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
  updateOrderItem(OrderItem object, orderId, totalAmount) async {
    var response = await http.post(Domain.orderItem, body: {
      'update': '1',
      'status': object.status,
      'price': object.price,
      'quantity': object.quantity,
      'remark': object.remark,
      'order_product_id': object.orderProductId.toString(),
      'order_id': orderId.toString(),
      'variation': object.variation,
      'total_amount': totalAmount
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
  * update delivery date & time
  * */
  updateDeliveryDate(date, time, orderId) async {
    var response = await http.post(Domain.orderItem, body: {
      'update': '1',
      'delivery_date': date,
      'delivery_time': time,
      'order_id': orderId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update order proof photo
  * */
  updateProofPhoto(orderId, imageCode) async {
    var response = await http.post(Domain.order, body: {
      'upload_proof_photo': '1',
      'image_code': imageCode,
      'order_id': orderId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update order delivery and tax
  * */
  updateShippingFeeAndTax(Order object) async {
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
  updateProfile(companyName, companyAddress, contactNumber, personInCharge,
      whatsAppNumber) async {
    var response = await http.post(Domain.profile, body: {
      'update': '1',
      'address': companyAddress,
      'phone': contactNumber,
      'name': personInCharge,
      'company_name': companyName,
      'whatsapp_number': whatsAppNumber,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update payment
  * */
  updatePayment(bankDetail, bankTransfer, cod, fpayTransfer, taxPercent) async {
    var response = await http.post(Domain.profile, body: {
      'update': '1',
      'bank_details': bankDetail,
      'cash_on_delivery': cod,
      'bank_transfer': bankTransfer,
      'fpay_transfer': fpayTransfer,
      'tax_percent': taxPercent,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update payment
  * */
  updateFPayDetail(fpayUsername, fpayApiKey, fpaySecretKey) async {
    var response = await http.post(Domain.profile, body: {
      'update': '1',
      'fpay_username': fpayUsername,
      'fpay_api_key': fpayApiKey,
      'fpay_secret_key': fpaySecretKey,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update order setting
  * */
  updateOrderSetting(emailOption, selfCollectOption, deliveryDateOption,
      deliveryTimeOption, orderMinDay, workingDay) async {
    var response = await http.post(Domain.profile, body: {
      'update': '1',
      'self_collect': selfCollectOption,
      'delivery_date_option': deliveryDateOption,
      'delivery_time_option': deliveryTimeOption,
      'email_option': emailOption,
      'order_min_day': orderMinDay,
      'working_day': workingDay,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update category
  * */
  updateCategory(name, categoryId) async {
    var response = await http.post(Domain.category, body: {
      'update': '1',
      'name': name,
      'category_id': categoryId,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * create product
  * */
  updateProduct(Product product, extension, imageCode, imageGalleryName,
      imageGalleryFile) async {
    print('category id: ${product.categoryId}');
    var response = await http.post(Domain.product, body: {
      'update': '1',
      'product_id': product.productId.toString(),
      'status': product.status.toString(),
      'description': product.description,
      'name': product.name,
      'price': product.price,
      'category_id': product.categoryId.toString(),
      'image_name': product.image,
      'variation': product.variation,
      'image_extension': extension,
      'image_code': imageCode,
      'image_gallery_name': imageGalleryName,
      'image_gallery_file': imageGalleryFile,
    });

    print(response.body);
    return jsonDecode(response.body);
  }

  /*
  * update password
  * */
  updateTokenStatus(token) async {
    var response = await http.post(Domain.registration, body: {
      'log_out': '1',
      'token': token,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * update group name
  * */
  updateGroupName(OrderGroup orderGroup) async {
    var response = await http.post(Domain.orderGroup, body: {
      'update': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'order_group_id': orderGroup.orderGroupId.toString(),
      'group_name': orderGroup.groupName,
    });
    return jsonDecode(response.body);
  }

  /*
  * update coupon
  * */
  updateCoupon(Coupon coupon, status) async {
    var response = await http.post(Domain.discount, body: {
      'update': '1',
      'id': coupon.couponId.toString(),
      'end_date': coupon.endDate,
      'start_date': coupon.startDate,
      'status': status.toString(),
      'discount_type': coupon.discountType,
      'discount_condition': coupon.discountCondition,
      'usage_limit_per_user': coupon.usageLimitPerUser,
      'usage_limit': coupon.usageLimit,
      'product_restriction': coupon.productRestriction,
      'coupon_code': coupon.couponCode,
      'form_id':
          Merchant.fromJson(await SharePreferences().read("merchant")).formId
    });
    return jsonDecode(response.body);
  }

  /*
  * update order delivery and tax
  * */
  updateDiscount(Order object) async {
    var response = await http.post(Domain.orderItem, body: {
      'update': '1',
      'discount_amount': object.discountAmount,
      'order_id': object.id.toString(),
    });
    return jsonDecode(response.body);
  }

  /*
  * update order delivery and tax
  * */
  updateFormSetting(FormSetting object, imageCode, extension) async {
    var response = await http.post(Domain.form, body: {
      'update': '1',
      'image_code': imageCode,
      'status': object.status.toString(),
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'banner_status': object.bannerStatus.toString(),
      'banner_video_link': object.bannerVideoLink,
      'form_color': object.formColor,
      'description': object.description,
      'name': object.name,
      'form_banner': object.formBanner,
      'image_extension': extension
    });
    return jsonDecode(response.body);
  }

  /*
  * update east west shipping
  * */
  updateEastWestShipping(EastWest object) async {
    var response = await http.post(Domain.shipping, body: {
      'update_east_west': '1',
      'status': object.status,
      'first_fee': object.firstFee,
      'price_point': object.pricePoint,
      'second_fee': object.secondFee,
      'id': object.id.toString()
    });
    return jsonDecode(response.body);
  }

  /*
  * update postcode shipping
  * */
  updatePostcodeShipping(postcode) async {
    var response = await http.post(Domain.shipping, body: {
      'update_postcode': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'shipping_by_postcode': postcode
    });
    return jsonDecode(response.body);
  }

  /*
  * update distance shipping
  * */
  updateDistanceShipping(distance, address, longitude, latitude) async {
    var response = await http.post(Domain.shipping, body: {
      'update_distance': '1',
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
      'shipping_by_distance': distance,
      'address_long_lat': address,
      'longitude': longitude,
      'latitude': latitude,
    });
    return jsonDecode(response.body);
  }

  /*
  * add order item
  * */
  addOrderItem(Product object, orderId, quantity, remark, totalAmount) async {
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
      'variation': object.variation,
      'total_amount': totalAmount
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

  /*
  * register device token
  * */
  registerDeviceToken(token) async {
    var response = await http.post(Domain.notification, body: {
      'register_token': '1',
      'token': token,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId
    });
    return jsonDecode(response.body);
  }

  /*
  * create category
  * */
  createCategory(name) async {
    var response = await http.post(Domain.category, body: {
      'create': '1',
      'name': name,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * create product
  * */
  createProduct(Product product, extension, imageCode, imageGalleryName,
      imageGalleryFile) async {
    var response = await http.post(Domain.product, body: {
      'create': '1',
      'status': product.status.toString(),
      'description': product.description,
      'name': product.name,
      'price': product.price,
      'category_id': product.categoryId.toString(),
      'image_name': product.image,
      'image_extension': extension,
      'image_code': imageCode,
      'image_gallery_name': imageGalleryName,
      'image_gallery_file': imageGalleryFile,
      'variation': product.variation,
      'form_id':
          Merchant.fromJson(await SharePreferences().read("merchant")).formId,
    });
    return jsonDecode(response.body);
  }

  /*
  * create coupon
  * */
  createCoupon(Coupon coupon, status) async {
    var response = await http.post(Domain.discount, body: {
      'create': '1',
      'end_date': coupon.endDate,
      'start_date': coupon.startDate,
      'status': status.toString(),
      'discount_type': coupon.discountType,
      'discount_condition': coupon.discountCondition,
      'usage_limit_per_user': coupon.usageLimitPerUser,
      'usage_limit': coupon.usageLimit,
      'product_restriction': coupon.productRestriction,
      'coupon_code': coupon.couponCode,
      'form_id':
          Merchant.fromJson(await SharePreferences().read("merchant")).formId,
    });
    return jsonDecode(response.body);
  }

  /*
  * apply coupon
  * */
  applyCoupon(Coupon coupon, discount, orderId) async {
    var response = await http.post(Domain.discount, body: {
      'create': '1',
      'coupon_id': coupon.couponId.toString(),
      'coupon_name': coupon.couponCode,
      'discount_amount': discount,
      'order_id': orderId,
    });
    return jsonDecode(response.body);
  }

  /*--------------------------------------------------------------------delete part-------------------------------------------------------------------------------*/
  /*
  * delete order item
  * */
  deleteOrderItem(orderProductId, orderId, totalAmount) async {
    var response = await http.post(Domain.orderItem, body: {
      'delete': '1',
      'order_product_id': orderProductId,
      'order_id': orderId,
      'total_amount': totalAmount,
    });
    return jsonDecode(response.body);
  }

  /*
  * delete order
  * */
  deleteOrder(orderIds) async {
    print('delete id here: $orderIds');
    var response = await http.post(Domain.order, body: {
      'delete': '1',
      'order_ids': orderIds,
    });
    return jsonDecode(response.body);
  }

  /*
  * delete category
  * */
  deleteCategory(categoryId) async {
    var response = await http.post(Domain.category, body: {
      'delete': '1',
      'category_id': categoryId,
    });
    return jsonDecode(response.body);
  }

  /*
  * delete product
  * */
  deleteProduct(productId) async {
    print('product id: $productId');
    var response = await http.post(Domain.product, body: {
      'delete': '1',
      'product_id': productId,
    });
    return jsonDecode(response.body);
  }

  /*
  * delete image gallery
  * */
  deleteImageGallery(imageGallery, imageName, productId) async {
    var response = await http.post(Domain.product, body: {
      'delete_gallery': '1',
      'image_gallery_name': imageGallery,
      'deleted_image_name': imageName,
      'product_id': productId,
    });
    return jsonDecode(response.body);
  }

  /*
  * delete product image
  * */
  deleteProductImage(imageName, productId) async {
    var response = await http.post(Domain.product, body: {
      'delete_image': '1',
      'deleted_image_name': imageName,
      'product_id': productId,
    });
    return jsonDecode(response.body);
  }

  /*
  * delete proof image
  * */
  deleteProofImage(imageName, orderId) async {
    var response = await http.post(Domain.order, body: {
      'delete_image': '1',
      'deleted_image_name': imageName,
      'order_id': orderId,
    });
    return jsonDecode(response.body);
  }

  /*
  * delete form banner
  * */
  deleteFormBanner(imageName) async {
    var response = await http.post(Domain.form, body: {
      'delete_image': '1',
      'deleted_image_name': imageName,
      'merchant_id':
          Merchant.fromJson(await SharePreferences().read("merchant"))
              .merchantId,
    });
    return jsonDecode(response.body);
  }

  /*
  * delete coupon
  * */
  deleteCoupon(couponId) async {
    var response = await http.post(Domain.discount,
        body: {'delete': '1', 'id': couponId.toString()});
    return jsonDecode(response.body);
  }

  /*
  * remove coupon
  * */
  removeCouponFromOrder(couponUsageId) async {
    var response = await http.post(Domain.discount, body: {
      'delete_coupon': '1',
      'coupon_usage_id': couponUsageId.toString()
    });
    return jsonDecode(response.body);
  }
}
