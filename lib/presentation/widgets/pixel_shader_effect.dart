import 'package:flutter/widgets.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class PixelShaderEffect extends StatelessWidget {
  const PixelShaderEffect({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      (context, shader, child) {
        return AnimatedSampler(
          (image, size, canvas) {
            shader
              ..setFloatUniforms((uniforms) {
                uniforms
                  ..setFloat(16)
                  ..setFloat(16)
                  ..setSize(size);
              })
              ..setImageSampler(0, image);

            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Paint()..shader = shader,
            );
          },
          child: child!,
        );
      },
      assetKey: 'packages/flutter_shaders/shaders/pixelation.frag',
      child: child,
    );
  }
}
