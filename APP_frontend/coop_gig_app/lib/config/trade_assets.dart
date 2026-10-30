import 'package:flutter/material.dart';

class TradeServiceMetadata {
  final String title;
  final String subtitle;
  final String startingPrice;
  final String tag;
  final String imageUrl;
  final String iconEmoji;
  final IconData iconData;
  final Color accentColor;
  final List<Color> gradientColors;

  const TradeServiceMetadata({
    required this.title,
    required this.subtitle,
    required this.startingPrice,
    required this.tag,
    required this.imageUrl,
    required this.iconEmoji,
    required this.iconData,
    required this.accentColor,
    required this.gradientColors,
  });
}

class TradeAssets {
  static const Map<String, TradeServiceMetadata> tradeData = {
    'Cleaning': TradeServiceMetadata(
      title: 'Cleaning',
      subtitle: 'Home, Kitchen & Bathroom deep sanitization',
      startingPrice: '₹399',
      tag: '⭐ 4.8 · Most Booked',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=700&q=80',
      iconEmoji: '🧹',
      iconData: Icons.cleaning_services_rounded,
      accentColor: Color(0xFF0284C7),
      gradientColors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF0EA5E9)],
    ),
    'Electrical': TradeServiceMetadata(
      title: 'Electrical',
      subtitle: 'Certified wiring, switches, sockets & appliance fix',
      startingPrice: '₹199',
      tag: '⚡ 15 min Dispatch',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=700&q=80',
      iconEmoji: '⚡',
      iconData: Icons.bolt_rounded,
      accentColor: Color(0xFFD97706),
      gradientColors: [Color(0xFFB45309), Color(0xFFD97706), Color(0xFFF59E0B)],
    ),
    'Plumbing': TradeServiceMetadata(
      title: 'Plumbing',
      subtitle: 'Leak repairs, tap fittings, pipe blocks & geysers',
      startingPrice: '₹199',
      tag: '🔧 Society Verified',
      imageUrl: 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?auto=format&fit=crop&w=700&q=80',
      iconEmoji: '🔧',
      iconData: Icons.plumbing_rounded,
      accentColor: Color(0xFF0F766E),
      gradientColors: [Color(0xFF115E59), Color(0xFF0F766E), Color(0xFF14B8A6)],
    ),
    'Carpentry': TradeServiceMetadata(
      title: 'Carpentry',
      subtitle: 'Furniture restoration, hinges, locks & custom fit',
      startingPrice: '₹299',
      tag: '🪚 Master Artisans',
      imageUrl: 'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?auto=format&fit=crop&w=700&q=80',
      iconEmoji: '🪚',
      iconData: Icons.handyman_rounded,
      accentColor: Color(0xFF9A3412),
      gradientColors: [Color(0xFF7C2D12), Color(0xFF9A3412), Color(0xFFEA580C)],
    ),
  };

  static TradeServiceMetadata getMetadata(String categoryName) {
    return tradeData[categoryName] ??
        TradeServiceMetadata(
          title: categoryName,
          subtitle: 'Society verified tradesperson dispatched under 5 km',
          startingPrice: '₹299',
          tag: '100% Verified',
          imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=700&q=80',
          iconEmoji: '🛠',
          iconData: Icons.build_circle_rounded,
          accentColor: const Color(0xFF0284C7),
          gradientColors: const [Color(0xFF0369A1), Color(0xFF0284C7)],
        );
  }

  // Bulletproof Trade Card Art: Always shows vibrant gradient artwork
  // and smoothly blends photo when network is available (never goes black!)
  static Widget buildTradeCardBackground(TradeServiceMetadata metadata) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base Vibrant Gradient Canvas
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: metadata.gradientColors,
            ),
          ),
        ),
        // Decorative Watermark Artisan Pattern
        Positioned(
          right: -14,
          bottom: -14,
          child: Opacity(
            opacity: 0.18,
            child: Icon(
              metadata.iconData,
              size: 130,
              color: Colors.white,
            ),
          ),
        ),
        // Network Image with smooth fade & fallback to vibrant gradient
        Image.network(
          metadata.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox.shrink(); // Stays on gradient while loading
          },
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink(); // Stays on vibrant gradient on network/CORS error!
          },
        ),
        // Scrim overlay for crisp white text legibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.85),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  // Fallback avatars with beautiful initials & gradient
  static const List<List<Color>> avatarGradients = [
    [Color(0xFF0284C7), Color(0xFF38BDF8)],
    [Color(0xFF059669), Color(0xFF34D399)],
    [Color(0xFFD97706), Color(0xFFFBBF24)],
    [Color(0xFF7C3AED), Color(0xFFA78BFA)],
  ];

  static List<Color> getAvatarGradient(int id) {
    return avatarGradients[id % avatarGradients.length];
  }
}
