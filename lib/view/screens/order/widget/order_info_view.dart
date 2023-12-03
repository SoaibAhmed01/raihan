import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/data/model/response/timeslote_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/address/widget/map_widget.dart';
import 'package:flutter_grocery/view/screens/order/widget/ordered_product_list_view.dart';
import 'package:provider/provider.dart';

class OrderInfoView extends StatelessWidget {
  final OrderModel? orderModel;
  final TimeSlotModel? timeSlot;

  const OrderInfoView({Key? key, required this.orderModel, required this.timeSlot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('${getTranslated('order_id', context)}:', style: poppinsRegular),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              
              Text(orderProvider.trackModel!.id.toString(), style: poppinsMedium),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              const Expanded(child: SizedBox()),
              
              const Icon(Icons.watch_later, size: 17),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              
              Flexible(child: Text(DateConverter.isoStringToLocalDateOnly(orderProvider.trackModel!.createdAt!), style: poppinsMedium)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            if(timeSlot != null) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
              Row(children: [
                Text('${getTranslated('delivered_time', context)}:', style: poppinsRegular),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(DateConverter.convertTimeRange(timeSlot!.startTime!, timeSlot!.endTime!, context), style: poppinsMedium),
              ]),

              Card(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                child: Text(
                  getTranslated(orderProvider.trackModel!.orderStatus, context),
                  style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                ),
              )),
            ]),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(children: [
              Text('${getTranslated('item', context)}:', style: poppinsRegular),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(orderProvider.orderDetails!.length.toString(), style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor)),
              const Expanded(child: SizedBox()),

              orderProvider.trackModel!.orderType == 'delivery' ? TextButton.icon(
                onPressed: () {
                  if(orderProvider.trackModel!.deliveryAddress != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MapWidget(address: orderProvider.trackModel!.deliveryAddress)));
                  }
                  else{
                    showCustomSnackBar(getTranslated('address_not_found', context), isError: true);
                  }
                },
                icon: Icon(Icons.map, size: 18, color: Theme.of(context).primaryColor,),
                label: Text(getTranslated('delivery_address', context), style: poppinsRegular.copyWith( color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(width: 1)),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    minimumSize: const Size(1, 30)
                ),
              ) : orderProvider.trackModel!.orderType == 'pos' ? Text(getTranslated('pos_order', context), style: poppinsRegular) : Text(getTranslated('self_pickup', context), style: poppinsRegular),
            ]),
            const Divider(height: Dimensions.paddingSizeLarge),


            // Payment info
            Align(alignment: Alignment.center, child: Text(
              getTranslated('payment_info', context),
              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
            )),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Row(children: [
              Expanded(flex: 3, child: Text('${getTranslated('status', context)}:', style: poppinsRegular)),

              Expanded(flex: 8, child: Text(
                getTranslated(orderProvider.trackModel!.paymentStatus, context),
                style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
              )),

            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Row(children: [
              Expanded(flex: 3, child: Text(getTranslated('method', context), style: poppinsRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),

              Expanded(flex: 8, child: Row(children: [
                (orderProvider.trackModel!.paymentMethod != null && orderProvider.trackModel!.paymentMethod!.isNotEmpty) && orderProvider.trackModel!.paymentMethod == 'cash_on_delivery' ? Text(
                  getTranslated('cash_on_delivery', context),style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                ) :
                Text(
                  (orderProvider.trackModel!.paymentMethod != null && orderProvider.trackModel!.paymentMethod!.isNotEmpty)
                      ? '${orderProvider.trackModel!.paymentMethod![0].toUpperCase()}${orderProvider.trackModel!.paymentMethod!.substring(1).replaceAll('_', ' ')}'
                      : 'Digital Payment',
                  style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                ),

              ])),


            ]),
            const Divider(height: 40),

            const OrderedProductListView(),


            (orderProvider.trackModel!.orderNote != null && orderProvider.trackModel!.orderNote!.isNotEmpty) ? Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6)),
              ),
              child: Text(orderProvider.trackModel!.orderNote!, style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
            ) : const SizedBox(),

          ],
        );
      }
    );
  }
}


