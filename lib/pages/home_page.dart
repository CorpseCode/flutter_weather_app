import 'package:country_state_city/models/city.dart';
import 'package:country_state_city/utils/city_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app_tutorial/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf =
      WeatherFactory(OPENWEATHER_API_KEY, language: Language.ENGLISH);

  TextEditingController controller = TextEditingController();

  Weather? _weather;

  String city = 'Lucknow';

  bool isValid = true;

  @override
  void initState() {
    super.initState();
    _wf.currentWeatherByCityName(city).then((w) {
      setState(() {
        _weather = w;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _weather == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SafeArea(
            child: Scaffold(
              // appBar: AppBar(
              //   title: Text(
              //     city,
              //     style: const TextStyle(
              //         color: Colors.white, fontWeight: FontWeight.w500),
              //   ),
              //   backgroundColor: Colors.deepPurpleAccent,
              // ),
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16, 16.0, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          height: 48,
                          width: MediaQuery.of(context).size.width - 90,
                          child: TextFormField(
                            controller: controller,
                            cursorOpacityAnimates: true,
                            cursorColor: Colors.deepPurple,
                            cursorRadius: const Radius.circular(8),
                            decoration: InputDecoration(
                              label: const Text('City'),
                              hintStyle: isValid
                                  ? const TextStyle()
                                  : const TextStyle(color: Colors.red),
                              hintText:
                                  isValid ? 'Enter City' : 'Invalid answer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      isValid ? Colors.deepPurple : Colors.red,
                                ),
                              ),
                            ),
                            autofillHints: cities,
                            enableSuggestions: true,
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.deepPurpleAccent),
                          child: IconButton(
                            onPressed: () {
                              if (kDebugMode) {
                                print(cities);
                              }
                              city = controller.text.trim();
                              if (cities.contains(city)) {
                                setState(() {
                                  _weather=null;
                                });
                                _wf.currentWeatherByCityName(city).then(
                                      (w) => setState(
                                        () {
                                          controller.text = '';
                                          _weather = w;
                                        },
                                      ),
                                    );
                              } // if block
                              else {
                                setState(() {
                                  controller.text = '';
                                  city = 'Enter a City';
                                  isValid = false;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    _buildUI(),
                  ],
                ),
              ), //adding the custom UI according to the different values
            ),
          );
  }

  //Custom UI code below.
  Widget _buildUI() {
    if (_weather == null) {
      //when the current weather data is not fetched we eill just show a loading screen
      return const Scaffold(
        backgroundColor: Colors.white,
        body:  Center(
          child: CircularProgressIndicator(backgroundColor: Colors.white,color: Colors.deepPurple,),
        ),
      );
    }
    //and if weather status is fetched we are going to show the below UI to the user
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          const Expanded(flex:12 ,child: SizedBox()),
          locationHeader(),
          const Expanded(flex:1 ,child: SizedBox()),
          currentTemp(),
          const Expanded(flex:12 ,child: SizedBox()),
          dateTimeInfo(),
          const Expanded(flex:1 ,child: SizedBox()),
          weatherIcon(),
          const Expanded(flex:12 ,child: SizedBox()),
          extraInfo(),
        ],
      ),
    );
  }

  Widget locationHeader() {
    return Text(
      _weather?.areaName ?? "",
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
            fontSize: 40,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${DateFormat("EEE").format(now)}  |',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16
              ),
            ),
            Text(
              "  ${DateFormat("dd MMM yy").format(now)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsPrecision(3)}°C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 90,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      padding: const EdgeInsets.all(
        16.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsPrecision(3)} °C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsPrecision(3)} °C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
