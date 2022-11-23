
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:band_names/models/band.dart';


class HomePage extends StatefulWidget {
 const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);
    
    super.initState();
  }

  _handleActiveBands(dynamic data){
      bands = (data as List).map((band) => Band.fromMap(band)).toList();
      setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BadNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: 
            (socketService.serverStatus == ServerStatus.online) 
              ? const Icon(Icons.check_circle, color: Colors.blue,)
              : const Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: Column(
        children: [
          
          _showGraph(bands),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewband,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
   );
  }


  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white))
        ),
      ),
      child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(band.name.substring(0,2)),
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20),),
            onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
          ),
    );
  }


  addNewband(){
    
    final textController = TextEditingController();

    if(Platform.isAndroid){
      return showDialog(
        context: context, 
        builder: ( _ ) {
          return AlertDialog(
            title: const Text('New Band Name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                onPressed: () => addBandToList(textController.text),
                elevation: 5,
                textColor: Colors.blue,
                child: const Text('Add'),
              )
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( _ ) {
        return CupertinoAlertDialog(
          title: const Text('New Band Name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            )  
          ],
        );
      },
    );


  }

  void addBandToList(String name){
    if(name.length > 1){
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
      
    }
    Navigator.pop(context);
  }

  Widget _showGraph(bandas) {
    
    Map<String, double> dataMap = {};

    for (var band in bandas) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }


    final colorList = <Color>[
      Colors.blue,
      Colors.blueAccent,
      Colors.pink,
      Colors.pinkAccent,
      Colors.yellow,
      Colors.yellowAccent,
    ];

    if(dataMap.isEmpty) return Container();

    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 200,
      child: 
      
      // PieChart(dataMap: dataMap) 
      
      PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "HYBRID",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          // legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );

  }
}