import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;


enum ServerStatus {
  online,
  offline,
  connecting
}

class SocketService with ChangeNotifier {

  ServerStatus _serverStatus = ServerStatus.connecting;
  late io.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  io.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketService(){
    _initConfig();
  }

  void _initConfig(){
    
    // Dart client
    _socket = io.io('http://localhost:3000', 
      io.OptionBuilder().setTransports(['websocket']).enableAutoConnect().build()
    );

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    _socket.on('nuevo-mensaje', (data) {
      // print(data);
    });

    
  }


}