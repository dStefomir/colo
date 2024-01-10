import 'package:colo/module/game/page.dart';
import 'package:colo/module/overlay/provider.dart';
import 'package:colo/widgets/blur.dart';
import 'package:colo/widgets/button.dart';
import 'package:colo/widgets/load.dart';
import 'package:colo/widgets/shadow.dart';
import 'package:colo/widgets/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// In app purchases ids
const List<String> _productIds = [
  'difficulty_select',
  'premium',
  'game_ads',
  'rocket_limiter'
];

class GameStoreDialog extends HookConsumerWidget {

  const GameStoreDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = InAppPurchase.instance;

    return FutureBuilder<bool>(
        future: purchases.isAvailable(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: LoadingIndicator(color: Colors.purple)
            );
          }

          if (snapshot.data! == false) {
            return Center(
                child: StyledText(
                  text: 'There are no upgrades at this time',
                  fontSize: 14,
                  align: TextAlign.start,
                  letterSpacing: 2,
                  gradientColors: List.generate(barColors.values.length, (index) {
                    final color = barColors.values.toList()[index];

                    return Color.fromRGBO(color.red, color.green, color.blue, 0.6);
                  }),
                  weight: FontWeight.bold,
                  useShadow: true,
                )
            );
          } else {
            return FutureBuilder<ProductDetailsResponse>(
                future: purchases.queryProductDetails(_productIds.toSet()),
                builder: (context, details) {
                  String? error;
                  if (!snapshot.hasData) {

                    return const Center(
                        child: LoadingIndicator(color: Colors.purple)
                    );
                  }

                  if (details.data == null) {
                    return const Center(
                        child: LoadingIndicator(color: Colors.purple)
                    );
                  }
                  /// Available products to sell
                  final List<ProductDetails> products = details.data!.productDetails;

                  if (details.data!.error != null) {
                    error = 'No connection with the store';
                  } else if (products.isEmpty) {
                    error = 'Store is empty';
                  }

                  if (error != null) {
                    return ShadowWidget(
                      child: Container(
                        color: Colors.black54,
                        width: double.infinity,
                        child: StyledText(
                          text: error,
                          fontSize: 25,
                          clip: false,
                          align: TextAlign.center,
                          letterSpacing: 2,
                          gradientColors: barColors.values.toList(),
                          weight: FontWeight.bold,
                          useShadow: true,
                        ),
                      ),
                    );
                  }
                  return _GameStoreBody(products: products);
                }
            );
          }
        });
  }
}

/// Renders the game store dialog body
class _GameStoreBody extends HookConsumerWidget {
  /// Available products for sale
  final List<ProductDetails> products;

  const _GameStoreBody({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool? shouldShowGameStoreDialog = ref.watch(overlayVisibilityProvider(const Key('game_store')));
    final body = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              DefaultButton(
                  onClick: () => ref.read(overlayVisibilityProvider(const Key('game_store')).notifier).setOverlayVisibility(false),
                  color: Colors.black,
                  svgColor: Colors.pink.withOpacity(0.5),
                  borderColor: Colors.black,
                  icon: 'assets/svgs/close.svg'
              ),
            ],
          ),
          ...products.map((product) {
            final purchaseParam = PurchaseParam(productDetails: product);
            return ShadowWidget(
              child: Card(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyledText(
                            text: product.title,
                            fontSize: 18,
                            align: TextAlign.start,
                            clip: false,
                            letterSpacing: 2,
                            gradientColors: barColors.values.toList(),
                            weight: FontWeight.bold,
                          ),
                          StyledText(
                            text: product.description,
                            fontSize: 12,
                            clip: false,
                            padding: const EdgeInsets.only(left: 15, bottom: 15),
                            align: TextAlign.start,
                            letterSpacing: 2,
                            gradientColors: barColors.values.toList(),
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 15, top: 20),
                      child: NormalButton(
                          color: Colors.pink.withOpacity(0.3),
                          text: StyledText(
                            family: 'RenegadePursuit',
                            gradientColors: barColors.values.toList(),
                            text: product.price,
                            fontSize: 13,
                            align: TextAlign.start,
                            color: Colors.white,
                            weight: FontWeight.bold,
                          ),
                          onClick: () async {
                            final wasPurchaseSuccessful = await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
                            if (kDebugMode) {
                              print(wasPurchaseSuccessful);
                            }
                          }
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList()
        ],
      ),
    );

    return shouldShowGameStoreDialog != null && shouldShowGameStoreDialog ? Blurrable(
      strength: 5,
      child: body,
    ) : body;
  }
}