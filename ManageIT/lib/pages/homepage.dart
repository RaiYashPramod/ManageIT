// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_management/controllers/db_helper.dart';
import 'package:money_management/modals/transaction_modal.dart';
import 'package:money_management/pages/add_name.dart';
import 'package:money_management/pages/add_transaction.dart';
import 'package:money_management/pages/todo_homepage.dart';
import 'package:money_management/pages/widgets/confirm_dialog.dart';
import 'package:money_management/static.dart' as Static;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/change_dailog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DbHelper dbHelper = DbHelper();
  DateTime today = DateTime.now();
  late SharedPreferences preferences;
  late Box box;
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpense = 0;
  List<FlSpot> dataSet = [];

  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  List<FlSpot> getPlotPoints(List<TransactionModal> entireData) {
    dataSet = [];
    // entireData.forEach((key, value) {
    //   if (value['type'] == "Expense" &&
    //       (value['date'] as DateTime).month == today.month) {
    //     dataSet.add(FlSpot((value['date'] as DateTime).day.toDouble(),
    //         (value['amount'] as int).toDouble()));
    //   }
    // });

    List tempDataSet = [];

    for (TransactionModal data in entireData) {
      if (data.date.month == today.month && data.type == "Expense") {
        tempDataSet.add(data);
      }
    }

    tempDataSet.sort((a, b) => a.date.day.compareTo(b.date.day));

    for (var i = 0; i < tempDataSet.length; i++) {
      dataSet.add(
        FlSpot(tempDataSet[i].date.day.toDouble(),
            tempDataSet[i].amount.toDouble()),
      );
    }

    return dataSet;
  }

  getTotalBalance(List<TransactionModal> entireData) {
    totalBalance = 0;
    totalIncome = 0;
    totalExpense = 0;
    for (TransactionModal data in entireData) {
      if (data.date.month == today.month) {
        if (data.type == "Income") {
          totalBalance += data.amount;
          totalIncome += data.amount;
        } else {
          totalBalance -= data.amount;
          totalExpense += data.amount;
        }
      }
    }
  }

  getPreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<List<TransactionModal>> fetch() async {
    if (box.values.isEmpty) {
      return Future.value([]);
    } else {
      List<TransactionModal> items = [];
      box.toMap().values.forEach((element) {
        // print(element);
        items.add(
          TransactionModal(
            element['amount'] as int,
            element['date'] as DateTime,
            element['note'],
            element['type'] as String,
          ),
        );
      });
      return items;
    }
  }

  @override
  void initState() {
    super.initState();
    getPreference();
    box = Hive.box("money");
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        toolbarHeight: 0.0,
      ),
      backgroundColor: Color(0xffe2e7ef),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => AddTransaction(),
            ),
          )
              .whenComplete(() {
            setState(() {});
          });
        },
        backgroundColor: Static.PrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            16.0,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 32.0,
        ),
      ),
      body: FutureBuilder<List<TransactionModal>>(
        future: fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("UnExpected Error!"),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Text("No Data Found!"),
              );
            }
            getTotalBalance(snapshot.data!);
            getPlotPoints(snapshot.data!);
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) => AddName(),
                                ),
                              )
                                  .whenComplete(() {
                                setState(() {});
                              });
                            },
                            backgroundColor: Static.PrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12.0,
                              ),
                            ),
                            child: Icon(
                              Icons.account_box,
                              size: 32.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            "Welcome ${preferences.getString('name')}",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                              color: Static.PrimaryMaterialColor[800],
                            ),
                          ),
                        ],
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => TodoHome()),
                          );
                        },
                        // focusElevation: ,
                        backgroundColor: Static.PrimaryMaterialColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ),
                        ),
                        child: Icon(
                          Icons.add_task_rounded,
                          size: 35.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  margin: EdgeInsets.all(
                    12.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Static.PrimaryColor,
                          Colors.blueAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          24.0,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 8.0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Balance",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          "Rs. $totalBalance",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                            8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              cardIncome(
                                totalIncome.toString(),
                              ),
                              cardExpense(
                                totalExpense.toString(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //
                //
                //
                //
                Padding(
                  padding: EdgeInsets.all(
                    12.0,
                  ),
                  child: Text(
                    "Expense",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                //
                //
                //
                //
                dataSet.length < 2
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 40.0,
                        ),
                        child: Text(
                          "Not Enough Values to render chart",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 40.0,
                        ),
                        height: 400.0,
                        child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(
                              show: false,
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: getPlotPoints(snapshot.data!),
                                isCurved: false,
                                barWidth: 2.5,
                                colors: [
                                  Static.PrimaryColor,
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                //
                //
                //
                //
                Padding(
                  padding: EdgeInsets.all(
                    12.0,
                  ),
                  child: Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                //
                //
                //
                //
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    TransactionModal dataAtIndex;

                    try {
                      dataAtIndex = snapshot.data![index];
                    } catch (e) {
                      return Container();
                    }

                    if (dataAtIndex.type == "Income") {
                      return incomeTile(
                        dataAtIndex.amount,
                        dataAtIndex.note,
                        dataAtIndex.date,
                        index,
                      );
                    } else {
                      return expenseTile(
                        dataAtIndex.amount,
                        dataAtIndex.note,
                        dataAtIndex.date,
                        index,
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 70.0,
                ),
              ],
            );
          } else {
            return Center(
              child: Text("UnExpected Error!"),
            );
          }
        },
      ),
    );
  }

  Widget cardIncome(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: EdgeInsets.all(
            6.0,
          ),
          child: Icon(
            Icons.arrow_downward,
            size: 28.0,
            color: Colors.green[500],
          ),
          margin: EdgeInsets.only(
            right: 8.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Income",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget cardExpense(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: EdgeInsets.all(
            6.0,
          ),
          child: Icon(
            Icons.arrow_upward,
            size: 28.0,
            color: Colors.red[700],
          ),
          margin: EdgeInsets.only(
            right: 8.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Expense",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget expenseTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
          context,
          "WARNING",
          "Do you want to delete this record?",
        );
        if (answer != null && answer) {
          dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.all(
          8.0,
        ),
        padding: EdgeInsets.all(
          18.0,
        ),
        decoration: BoxDecoration(
          color: Color(
            0xffced4eb,
          ),
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_up_outlined,
                      size: 29.0,
                      color: Colors.red[700],
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "Expense",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "${date.day} ${months[date.month - 1]}",
                    style: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: 18.0,
                      // fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "- $value",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(
                    color: Colors.grey[800],
                    // fontSize: 18.0,
                    // fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget incomeTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
          context,
          "WARNING",
          "Do you want to delete this record?",
        );
        if (answer != null && answer) {
          dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.all(
          8.0,
        ),
        padding: EdgeInsets.all(
          18.0,
        ),
        decoration: BoxDecoration(
          color: Color(
            0xffced4eb,
          ),
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_down_outlined,
                      size: 29.0,
                      color: Colors.green[700],
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "Income",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "${date.day} ${months[date.month - 1]}",
                    style: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: 18.0,
                      // fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "+ $value",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(
                    color: Colors.grey[800],
                    // fontSize: 18.0,
                    // fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
