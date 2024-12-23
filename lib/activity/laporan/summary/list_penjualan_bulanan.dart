import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/penjualan/input_penjualan.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

import '../../utility/bottom_modal_filter.dart';

class ListPenjualanBulanan extends StatefulWidget {
  const ListPenjualanBulanan({Key? key}) : super(key: key);

  @override
  State<ListPenjualanBulanan> createState() => _ListPenjualanBulananState();
}

class _ListPenjualanBulananState extends State<ListPenjualanBulanan> {
  Future<List<dynamic>>? _dataPenjualanBulanan;
  dynamic _dataMastePenjualanBulanan;
  TextEditingController tanggalDariCtrl = TextEditingController();
  TextEditingController tanggalHinggaCtrl = TextEditingController();

  Future<List<dynamic>> _getDataPenjualanBulanan(
      {String tglDari = "",
      String tglHingga = "",
      String idDept = "",
      String idPengguna = ""}) async {
    if (tglDari == "") {
      tglDari = Utils.fisrtDateOfMonthString();
    }

    if (tglHingga == "") {
      tglHingga = Utils.formatStdDate(DateTime.now());
    }

    if (idDept == "") {
      idDept = Utils.idDeptTemp;
    }

    if (idPengguna == "") {
      idPengguna = Utils.idPenggunaTemp;
    }

    Uri url = Uri.parse(
        "${Utils.mainUrl}home/penjualanbulanan?idpengguna=$idPengguna&iddept=$idDept&tgldari=$tglDari&tglhingga=$tglHingga");
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    _dataMastePenjualanBulanan = await jsonData["header"];
    return jsonData["detail"];
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataPenjualanBulanan = _getDataPenjualanBulanan();
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPenjualanBulanan,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 0,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Utils.labelValueSetter("Periode",
                            "${Utils.formatDate(_dataMastePenjualanBulanan["TANGGAL_DARI"])} - ${Utils.formatDate(_dataMastePenjualanBulanan["TANGGAL_HINGGA"])}"),
                        Utils.labelValueSetter("Department", Utils.namaDeptTemp),
                        Utils.labelValueSetter("Bagian Penjualan", Utils.namaPenggunaTemp),
                        Utils.labelValueSetter("Total Penjualan Tunai",
                            Utils.formatNumber(_dataMastePenjualanBulanan["TOTAL_PENJUALAN_TUNAI"]),
                            boldValue: true, sizeValue: 15, flexLabel: 2),
                        Utils.labelValueSetter(
                            "Total Penjualan Kredit",
                            Utils.formatNumber(
                                _dataMastePenjualanBulanan["TOTAL_PENJUALAN_KREDIT"]),
                            boldValue: true,
                            sizeValue: 15,
                            flexLabel: 2)
                      ],
                    ),
                  )),
              Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext contex, int index) {
                      dynamic dataList = snapshot.data![index];
                      return Container(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Utils.bagde((index + 1).toString()),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Utils.labelValueSetter("Tipe", dataList["TIPE_PENJUALAN"]),
                                        Utils.labelValueSetter("Department", dataList["NAMA_DEPT"]),
                                        Utils.labelValueSetter(
                                            "Bagian Penjualan", dataList["BAGIAN_PENJUALAN"]),
                                        Utils.labelValueSetter("Total Penjualan",
                                            Utils.formatNumber(dataList["TOTAL_PENJUALAN"]),
                                            boldValue: true),
                                        Container(
                                          padding: EdgeInsets.only(top: 10),
                                          alignment: Alignment.bottomRight,
                                          child: Utils.labelSetter(
                                              Utils.formatDate(dataList["TANGGAL"]),
                                              size: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          );
        }
      }),
    );
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Daftar Penjualan Bulanan");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
              onPressed: () {
                dateBottomModal(context);
              },
              icon: Icon(Icons.filter_list_alt))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customSearchBar = Text("Daftar Penjualan Bulanan");
              _dataPenjualanBulanan = _getDataPenjualanBulanan();
              tanggalDariCtrl.text = "";
              tanggalHinggaCtrl.text = "";
            });
          });
        },
        child: Container(
          child: setListFutureBuilder(),
        ),
      ),
    );
  }

  dateBottomModal(BuildContext context) async {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return BottomModalFilter(
              tanggalDariCtrl: tanggalDariCtrl,
              tanggalHinggaCtrl: tanggalHinggaCtrl,
              isDept: true,
              isPengguna: true,
              action: () {
                Navigator.pop(context);
                Future.delayed(Duration(seconds: 2));
                setState(() {
                  _dataPenjualanBulanan = _getDataPenjualanBulanan(
                      tglDari: tanggalDariCtrl.text,
                      tglHingga: tanggalHinggaCtrl.text,
                      idDept: Utils.idDeptTemp,
                      idPengguna: Utils.idPenggunaTemp);
                });
              });
        });
  }
}
