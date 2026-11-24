import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

enum DevicePreset {
  iphone15Pro('iPhone 15 Pro', 393, 852, 54),
  pixel8('Google Pixel 8', 412, 892, 44),
  galaxyS24('Galaxy S24', 390, 844, 48),
  responsive('Full Screen', 0, 0, 0);

  final String label;
  final double width;
  final double height;
  final double cornerRadius;

  const DevicePreset(this.label, this.width, this.height, this.cornerRadius);
}

class VirtualDeviceEmulator extends StatefulWidget {
  final Widget child;

  const VirtualDeviceEmulator({super.key, required this.child});

  @override
  State<VirtualDeviceEmulator> createState() => _VirtualDeviceEmulatorState();
}

class _VirtualDeviceEmulatorState extends State<VirtualDeviceEmulator> {
  DevicePreset _selectedDevice = DevicePreset.iphone15Pro;
  bool _isEmulatorEnabled = true;
  final double _zoomLevel = 0.95; // default 95% zoom to comfortably fit most laptop heights
  late String _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateTime());
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('h:mm').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // On mobile screens (< 520px width), always render native full screen
    if (screenSize.width < 520 || !_isEmulatorEnabled || _selectedDevice == DevicePreset.responsive) {
      return Stack(
        children: [
          widget.child,
          // Floating button to re-enable emulator if on wide screen
          if (screenSize.width >= 520)
            Positioned(
              top: 14,
              right: 14,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _isEmulatorEnabled = true),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreenDark.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_iphone_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Phone Simulator',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // DESKTOP STUDIO CANVAS WITH VIRTUAL PHONE EMULATOR
    final targetWidth = _selectedDevice.width;
    final targetHeight = _selectedDevice.height;
    final radius = _selectedDevice.cornerRadius;

    // Available vertical space calculation
    final maxAvailableHeight = screenSize.height - 80;
    final scale = ((maxAvailableHeight / (targetHeight + 40)) * _zoomLevel).clamp(0.65, 1.05);

    return Scaffold(
      backgroundColor: const Color(0xFF1E2421), // Studio dark slate canvas
      body: SafeArea(
        child: Column(
          children: [
            // TOP STUDIO CONTROL DOCK
            _buildControlDock(context),

            // CENTERED EMULATOR WORKSPACE
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Transform.scale(
                      scale: scale,
                      child: _buildPhoneChassis(targetWidth, targetHeight, radius),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlDock(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141916),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.handshake_outlined, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CoopGig Virtual Device Simulator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '85/10/5 Fair Wage Model · Hyper-Local Dispatch',
                    style: TextStyle(color: Colors.white54, fontSize: 10.5),
                  ),
                ],
              ),
            ],
          ),

          // Device Switcher Pills
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...DevicePreset.values.where((d) => d != DevicePreset.responsive).map((device) {
                final isSelected = _selectedDevice == device;
                return ChoiceChip(
                  label: Text(device.label),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedDevice = device);
                  },
                  selectedColor: AppColors.forestGreen,
                  backgroundColor: const Color(0xFF28312B),
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(
                    color: isSelected ? AppColors.forestGreenLight : Colors.transparent,
                  ),
                );
              }),
              const SizedBox(width: 8),
              // Full Screen Toggle
              IconButton(
                icon: const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 20),
                tooltip: 'Exit to Full Screen Mode',
                onPressed: () => setState(() => _isEmulatorEnabled = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneChassis(double width, double height, double cornerRadius) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // LEFT HARDWARE BUTTONS (Volume up, volume down)
        Positioned(
          left: -4,
          top: 140,
          child: Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3F4742),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Positioned(
          left: -4,
          top: 200,
          child: Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3F4742),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // RIGHT HARDWARE BUTTON (Power)
        Positioned(
          right: -4,
          top: 170,
          child: Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF3F4742),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // MAIN PHONE BODY (Outer rim + bezel + shadow)
        Container(
          width: width + 24,
          height: height + 24,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B201D), // Matte Titanium edge
            borderRadius: BorderRadius.circular(cornerRadius + 8),
            border: Border.all(
              color: const Color(0xFF4B554F),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 36,
                spreadRadius: 8,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: AppColors.forestGreen.withValues(alpha: 0.15),
                blurRadius: 60,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: Stack(
              children: [
                // 1. THE FLUTTER APPLICATION
                Positioned.fill(
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(width, height),
                      padding: const EdgeInsets.only(top: 44, bottom: 20),
                      viewInsets: EdgeInsets.zero,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(cornerRadius),
                      child: widget.child,
                    ),
                  ),
                ),

                // 2. VIRTUAL MOBILE STATUS BAR
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 44,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Clock
                          Text(
                            _currentTime,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              letterSpacing: -0.2,
                            ),
                          ),
                          // System Icons
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.signal_cellular_4_bar_rounded, size: 14, color: Colors.black87),
                              SizedBox(width: 4),
                              Icon(Icons.wifi_rounded, size: 14, color: Colors.black87),
                              SizedBox(width: 6),
                              Icon(Icons.battery_full_rounded, size: 18, color: Colors.black87),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. TOP DYNAMIC ISLAND / CAMERA PILL
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IgnorePointer(
                      child: Container(
                        width: 116,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF161A22),
                                border: Border.all(color: const Color(0xFF2C3240), width: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. BOTTOM HOME INDICATOR PILL
                Positioned(
                  bottom: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IgnorePointer(
                      child: Container(
                        width: 135,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
