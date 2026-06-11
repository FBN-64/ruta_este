import 'package:flutter_test/flutter_test.dart';
// Importamos tu archivo principal
import 'package:ruta_este/main.dart';

void main() {
  testWidgets('Prueba de carga inicial de Ruta Este', (WidgetTester tester) async {
    // 1. Construimos nuestra app simulando que el usuario NO está logueado aún
    await tester.pumpWidget(const BusCheckApp(isLoggedIn: false));

    // 2. Verificamos que la pantalla cargue correctamente buscando los textos del Login
    expect(find.text('Ruta Este'), findsWidgets);
    expect(find.text('¿Cómo te llamamos?'), findsOneWidget);

    // 3. Verificamos que la app NO muestre el contador por defecto de Flutter
    expect(find.text('0'), findsNothing);
  });
}