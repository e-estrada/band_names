import 'package:flutter/material.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:provider/provider.dart';


class StatusPage extends StatelessWidget {
 const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.emit(event);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ServerStatus: ${socketService.serverStatus} ')
          ],
        ),
     ),
     floatingActionButton: FloatingActionButton(
      onPressed: () {
        socketService.emit('emitir-mensaje', {'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter'});
      },
      child: const Icon(Icons.message),
     ),
   );
  }
}