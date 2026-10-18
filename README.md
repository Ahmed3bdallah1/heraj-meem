# Noya - E-commerce Flutter Application

A Flutter e-commerce application with cart management functionality.

## Project Overview

This application implements a complete e-commerce solution with shopping cart management. The cart system has been updated to work without color and size variants, simplifying the product management.

## Cart System

### Cart Item Model

The `CartItemModel` has been updated to match the API response structure:

```dart
class CartItemModel {
  final int? id;              // Cart item ID
  final ProductModel? product; // Full product details
  final int? quantity;         // Quantity of the product
  final double? subtotal;      // Subtotal for this cart item
}
```

### Cart Use Cases

The cart system provides the following use cases:

1. **FetchCartItemsUseCase**: Fetches all cart items from the API
2. **AddToCartItemsUseCase**: Adds a product to the cart (takes productId as String)
3. **DeleteFromCartItemsUseCase**: Removes a product from the cart (takes productId as String)
4. **UpdateQuantityItemsUseCase**: Updates the quantity of a cart item (takes Tuple2<String, int> with productId and quantity)

### Cart Providers

#### fetchCartItemsProvider
- **Type**: `FutureProvider<List<CartItemModel>>`
- **Purpose**: Fetches all cart items
- **Usage**: `ref.watch(fetchCartItemsProvider)`

#### quantityProvider
- **Type**: `StateNotifierProvider.family<QuantityNotifier, Map<String, dynamic>, String>`
- **Purpose**: Manages quantity for a specific product
- **Parameter**: ProductId (String)
- **State**: Contains 'loading' and 'quantity' fields
- **Methods**:
  - `incrementQuantity()`: Increments quantity by 1 and adds to cart
  - `decrementQuantity()`: Decrements quantity by 1 and removes from cart when reaches 0
  - `syncWithCart(int quantity)`: Syncs with cart data without making backend calls

### Cart Widgets

#### AddToCartWidget
- Displays add/remove buttons and quantity controls
- Automatically syncs with cart state
- Takes a `ProductModel` as parameter

#### CartItemCard
- Displays individual cart items
- Supports swipe-to-delete functionality
- Shows product image, name, quantity, and subtotal

#### CartItemsScreen
- Main screen displaying all cart items
- Shows total and subtotal calculations
- Provides checkout button

## API Endpoints

- `GET /cart`: Fetches all cart items
- `POST /cart/{productId}`: Adds a product to cart
- `DELETE /cart/{productId}`: Removes a product from cart
- `PUT /cart/{productId}?quantity={quantity}`: Updates product quantity in cart

## Key Features

- ✅ No color/size variants - simplified cart management
- ✅ Real-time quantity synchronization
- ✅ Swipe-to-delete cart items
- ✅ Automatic subtotal calculation
- ✅ Loading states for better UX
- ✅ Error handling with user-friendly messages

## Recent Updates

1. Removed color and size variant support from cart system
2. Updated cart model to match API response structure
3. Fixed cart providers to work without variant keys
4. Implemented proper quantity management
5. Updated total price calculations to use subtotals from API
6. Redesigned cart UI with:
   - Custom brown AppBar with rounded bottom corners
   - Arabic text ("السلة") in the header
   - Selection checkboxes for each cart item
   - Integrated quantity controls with +/- buttons
   - Delete icons for quick item removal
   - White bottom sheet with rounded top corners
   - Total price display in Arabic format
   - Checkout button with item quantity badge
7. Registered all cart classes in dependency injection
8. Registered all favorites classes in dependency injection (FavoritesDataSource, FavoritesRepo, FetchFavoritesUseCase, AddOrDeleteFavoritesUseCase)
