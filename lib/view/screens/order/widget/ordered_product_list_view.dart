import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/order_details_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_image.dart';
import 'package:flutter_grocery/view/base/custom_single_child_list_view.dart';
import 'package:provider/provider.dart';

class OrderedProductListView extends StatelessWidget {
  const OrderedProductListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return CustomSingleChildListView(
      itemCount: orderProvider.orderDetails!.length,
      itemBuilder: (index) {
        return orderProvider.orderDetails![index].productDetails != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          OrderedProductItem(orderDetailsModel: orderProvider.orderDetails![index]),
          const Divider(height: 40),

        ]): const SizedBox.shrink();
      },
    );
  }
}

class OrderedProductItem extends StatelessWidget {
  final OrderDetailsModel orderDetailsModel;
  final bool fromReview;
  const OrderedProductItem({Key? key, required this.orderDetailsModel,this.fromReview = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomImage(
          placeholder: Images.getPlaceHolderImage(context),
          image: '${splashProvider.baseUrls!.productImageUrl}/'
              '${orderDetailsModel.productDetails!.image!.isNotEmpty
              ? orderDetailsModel.productDetails!.image![0] : ''}',
          height: 70, width: 80, fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  orderDetailsModel.productDetails!.name!,
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

             if(!fromReview) Row(children: [
                Text('${getTranslated('quantity', context)}:', style: poppinsRegular),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(orderDetailsModel.quantity.toString(), style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor)),
              ]),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Row(children: [
            CustomDirectionality(child: Text(
              PriceConverter.convertPrice(context, orderDetailsModel.price! - orderDetailsModel.discountOnProduct!.toDouble()),
              style: poppinsRegular,
            )),
            const SizedBox(width: 5),

            orderDetailsModel.discountOnProduct! > 0 ?
            Expanded(child: CustomDirectionality(
              child: Text(
                PriceConverter.convertPrice(context, orderDetailsModel.price!.toDouble()),
                style: poppinsRegular.copyWith(
                  decoration: TextDecoration.lineThrough,
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor.withOpacity(0.6),
                ),
              ),
            )) : const SizedBox(),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

         !fromReview && orderDetailsModel.variation != ''&& orderDetailsModel.variation != null?
          Row(children: [
            Container(height: 10, width: 10, decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            Text(orderDetailsModel.variation ?? '',
              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
          ]):const SizedBox(),
        ]),
      ),
    ]);
  }
}

