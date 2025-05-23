import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';
import 'additional_info_item.dart';
import 'hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  Future<Map<String,dynamic>> getCurrentWeather() async{
    try{
      String cityName = 'London';
      final res = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );

      final data=jsonDecode(res.body);

      if(data['cod'] != '200'){
        throw data['message'];
      }
      return data;

    }
    catch(e){
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Weather App',
          style: TextStyle(fontWeight: FontWeight.bold ),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            setState(() {}
            );
          },  icon: const Icon(Icons.refresh))
        ],
      ),
      body:FutureBuilder(
        future: getCurrentWeather(),
        builder:(context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: const CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentTemp = data['list'][0]['main']['temp'];
          final currentSky = data['list'][0]['weather'][0]['main'];
          final currentPressure = data['list'][0]['main']['pressure'];
          final currentHumidity = data['list'][0]['main']['humidity'];
          final currentWindSpeed = data['list'][0]['wind']['speed'];


          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //main card
              SizedBox(
                width: double.infinity,
                child:Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
                        child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('$currentTemp K', style:
                            TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
                            const SizedBox(height: 16,),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny
                              ,size: 64,),
                            const SizedBox(height: 16,),
                            Text(currentSky,style: TextStyle(fontSize: 20),)
                          ],
                        ),
                                        ),
                      ),
                    ),),

              ),

              const SizedBox(height: 20,),
              Text('Weather Forecast',style: TextStyle(
                  fontSize: 24,fontWeight: FontWeight.bold),),
              const SizedBox(height: 8,),
              SizedBox(
                height: 120,
                child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context,index){
                      final hourlyForecast=data['list'][ index +1];
                      final time=DateTime.parse(hourlyForecast['dt_txt']);
                      return HourlyForecastItem(
                          time: DateFormat.j().format(time),
                          temp: hourlyForecast['main']['temp'].toString(),
                          icon: hourlyForecast['weather'][0]['main'] == 'Clouds'|| hourlyForecast['weather'][0]['main'] == 'Rain'
                               ? Icons.cloud
                               : Icons.sunny,);
                    }),
              ),
              const SizedBox(height: 20,),
              //additional information
              Text('Additional Information',style: TextStyle(
                  fontSize: 24,fontWeight: FontWeight.bold),),
              const SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '$currentHumidity',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '$currentWindSpeed',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: '$currentPressure',
                  ),
                ],
              )
            ],
          ),
        );
        },
      ),
    );
  }
}







