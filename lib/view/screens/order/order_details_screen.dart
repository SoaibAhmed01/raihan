 import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/data/model/response/timeslote_model.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_shadow_view.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/order/widget/order_amount_view.dart';
import 'package:flutter_grocery/view/screens/order/widget/order_details_button_view.dart';
import 'package:flutter_grocery/view/screens/order/widget/order_info_view.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final String? phoneNumber;

  const OrderDetailsScreen({Key? key, required this.orderModel, required this.orderId, this.phoneNumber}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

 class _OrderDetailsScreenState extends State<OrderDetailsScreen> {

   void _loadData(BuildContext context) async {
     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
     final orderProvider = Provider.of<OrderProvider>(context, listen: false);


     orderProvider.trackOrder(widget.orderId.toString(), null, context, false, phoneNumber: widget.phoneNumber, isUpdate: false);

     if (widget.orderModel == null) {
       await splashProvider.initConfig();
     }
     await orderProvider.initializeTimeSlot();
     orderProvider.getOrderDetails(orderID: widget.orderId.toString(), phoneNumber: widget.phoneNumber);
   }

   @override
   void initState() {
     super.initState();
     _loadData(context);
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()): CustomAppBar(
         title: 'order_details'.tr,
       )) as PreferredSizeWidget?,
       body: Consumer<OrderProvider>(builder: (context, orderProvider, _) {

         double deliveryCharge = OrderHelper.getDeliveryCharge(orderModel: orderProvider.trackModel);
         double itemsPrice = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.itemPrice);
         double discount = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.discount);
         double extraDiscount = OrderHelper.getExtraDiscount(trackOrder: orderProvider.trackModel);
         double tax = OrderHelper.getOrderDetailsValue(orderDetailsList: orderProvider.orderDetails, type: OrderValue.tax);
         bool isVatInclude = OrderHelper.isVatTaxInclude(orderDetailsList: orderProvider.orderDetails);
         TimeSlotModel? timeSlot = OrderHelper.getTimeSlot(timeSlotList: orderProvider.allTimeSlots, timeSlotId: orderProvider.trackModel?.timeSlotId);

         double subTotal =  OrderHelper.getSubTotalAmount(itemsPrice: itemsPrice, tax: tax, isVatInclude: isVatInclude);

         double total = OrderHelper.getTotalOrderAmount(
           subTotal: subTotal, discount: discount, extraDiscount: extraDiscount,
           deliveryCharge: deliveryCharge, couponDiscount: orderProvider.trackModel?.couponDiscountAmount,
         );


         return (orderProvider.orderDetails == null || orderProvider.trackModel == null) ? Center(child: CustomLoader(color: Theme.of(context).primaryColor)) : orderProvider.orderDetails!.isNotEmpty ?  Column(
           children: [
             Expanded(child: CustomScrollView(slivers: [
               if(ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: Center(
                 child: Container(
                   width: Dimensions.webScreenWidth,
                   padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                   child: Padding(
                     padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(child: CustomShadowView(
                           padding: const EdgeInsets.symmetric(
                             horizontal: Dimensions.paddingSizeDefault,
                             vertical: Dimensions.paddingSizeDefault,
                           ),
                           child: OrderInfoView(orderModel: widget.orderModel, timeSlot: timeSlot),
                         )),
                         const SizedBox(width: Dimensions.paddingSizeLarge),

                         Expanded(child: CustomShadowView(
                           padding: const EdgeInsets.symmetric(
                             horizontal: Dimensions.paddingSizeDefault,
                             vertical: Dimensions.paddingSizeDefault,
                           ),
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.start,
                             children: [
                               OrderAmountView(
                                 itemsPrice: itemsPrice,
                                 tax: tax,
                                 subTotal: subTotal,
                                 discount: discount,
                                 couponDiscount: orderProvider.trackModel?.couponDiscountAmount ?? 0,
                                 deliveryCharge: deliveryCharge,
                                 total: total,
                                 isVatInclude: isVatInclude,
                                 paymentList: OrderHelper.getPaymentList(orderProvider.trackModel),
                               ),

                               OrderDetailsButtonView(orderModel: widget.orderModel, phoneNumber: widget.phoneNumber),

                             ],),
                         )),

                       ],
                     ),
                   ),
                 ),
               )),

               if(!ResponsiveHelper.isDesktop(context)) SliverToBoxAdapter(child: Column(children: [
                 Center(child: SizedBox(
                   width: 1170,
                   child: Padding(
                     padding: const EdgeInsets.symmetric(
                       horizontal: Dimensions.paddingSizeDefault,
                       vertical: Dimensions.paddingSizeDefault,
                     ),
                     child: Column(children: [
                       OrderInfoView(orderModel: widget.orderModel, timeSlot: timeSlot),

                       OrderAmountView(
                         itemsPrice: itemsPrice,
                         tax: tax,
                         subTotal: subTotal,
                         discount: discount,
                         couponDiscount: orderProvider.trackModel?.couponDiscountAmount ?? 0,
                         deliveryCharge: deliveryCharge,
                         total: total,
                         isVatInclude: isVatInclude,
                         paymentList: OrderHelper.getPaymentList(orderProvider.trackModel),
                       ),
                     ]),
                   ),
                 )),
               ])),


               if(ResponsiveHelper.isDesktop(context))  const SliverFillRemaining(
                 hasScrollBody: false,
                 child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                   SizedBox(height: Dimensions.paddingSizeLarge),

                   FooterView(),
                 ]),
               ),

             ])),

             if(!ResponsiveHelper.isDesktop(context)) CustomShadowView(
               borderRadius: Dimensions.radiusSizeLarge,
               padding: const EdgeInsets.symmetric(
                 horizontal: Dimensions.paddingSizeDefault,
                 vertical: Dimensions.paddingSizeDefault,
               ),
               child: OrderDetailsButtonView(orderModel: widget.orderModel, phoneNumber: widget.phoneNumber),
             ),

           ],

         ) : NoDataScreen(isShowButton: true, image: Images.box, title: 'order_not_found'.tr);
       }),
     );
   }
 }



class ItemView extends StatelessWidget {
  const ItemView({
    Key? key,
    required this.title,
    required this.subTitle,
    this.style,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: style ?? poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

      CustomDirectionality(child: Text(
        subTitle,
        style: style ?? poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
      )),
    ]);
  }
}




