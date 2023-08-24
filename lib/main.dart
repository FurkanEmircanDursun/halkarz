import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Halka Arz Hesaplayıcı',
      theme: ThemeData(
        textTheme: GoogleFonts.antonTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double halkaArzBuyuklugu = 0;
  int katilimciSayisi = 0;
  double hisseFiyati = 0;
  double tavanSerisi = 0;
  double sonuc = 0;
  bool showResult = false;
  bool calculating = false;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'tr', symbol: '');

  void _calculateResult() {
    if (halkaArzBuyuklugu <= 0 || katilimciSayisi <= 0 || hisseFiyati <= 0 || tavanSerisi <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Uyarı'),
          content: Text('Lütfen tüm alanları doldurun.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tamam'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      calculating = true;
      sonuc = (halkaArzBuyuklugu / katilimciSayisi) * hisseFiyati;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        calculating = false;
        showResult = true;
      });
    });
  }

  void _updateLotSayisi() {
    if (katilimciSayisi > 0) {
      sonuc = (halkaArzBuyuklugu / katilimciSayisi) * hisseFiyati;
    }
  }

  Widget _buildResultTable() {
    if (!showResult || sonuc <= 0) {
      return Container();
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width-50,
        child: Column(

          children: [
            DataTable(
              columns: [
                DataColumn(label: Text('Gün')),
                DataColumn(label: Text('Değer')),
                DataColumn(label: Text('Yüzdelik Değer')),
              ],
              rows: List<DataRow>.generate(
                tavanSerisi.toInt(),
                    (index) {
                  Color? rowColor = index % 2 == 0 ? Colors.blueGrey[300] : Colors.grey[200];
                  return DataRow(
                    color: MaterialStateColor.resolveWith((states) => rowColor!),
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(
                        Text(_currencyFormat.format(sonuc * pow(1.1, index + 1)) + "₺"),
                      ),
                      DataCell(
                        Text("%" + _currencyFormat.format(pow(1.1, index + 1) * 100)),
                      ),
                    ],
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF18242C),
        title: Text('Halka Arz Hesaplayıcı'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: SelectionArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Halka Arz Büyüklüğü'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      halkaArzBuyuklugu = double.tryParse(value) ?? 0;
                      _updateLotSayisi();
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: 'Katılımcı Sayısı'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      katilimciSayisi = int.tryParse(value) ?? 0;
                      _updateLotSayisi();
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: 'Hisse Fiyatı'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      hisseFiyati = double.tryParse(value) ?? 0;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: 'Tavan Serisi (Maks 100)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      tavanSerisi = double.tryParse(value) ?? 0;
                      if (tavanSerisi > 100) {
                        tavanSerisi = 100;
                      }
                    },
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton(
                        onPressed: calculating ? null : _calculateResult,
                        child: calculating
                            ? CircularProgressIndicator()
                            : Text('Hesapla'),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  showResult
                      ? Center(

                    child: Text(
                      "Toplam Hisse Değeri: ${_currencyFormat.format(sonuc)} ₺ / Lot Sayısı:${(halkaArzBuyuklugu / katilimciSayisi).toInt()} ",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                      : Container(),
                  _buildResultTable(),
                  SizedBox(height: 20),
                Center(child: Column(
                  children: [
                    Text(
                      'Türk Borsası ve Değer Değişimi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Türk borsası genellikle günlük bazda dalgalı hareket eder. Bu hesaplamada her gün %10 artış ile hesaplama yapıldı ancak gerçek durum farklılık gösterebilir.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Lütfen hesaplamaları yatırım kararı verirken temel alarak, uzman görüşleri ve piyasa analizleri ile destekleyin.',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Halka Arz Lot Hesaplama',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Gelelim halka arz şirketin size kaç lot vereceğine. Hadi bir örnek yapalım: ABC hissesi 10.000.000 lot dağıtacak ve 1 lot fiyatını 15 TL olarak belirledi. Siz önceki halka arza katılan sayısına baktınız 500.000 civarı.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Geçelim hesaplamaya >> Kişi başına düşecek lot adet: 10.000.000 / 500.000 = 20 lot. 20 * 15 = 300 TL',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Yani beklediğimiz gibi katılım olursa halka arza 300 TL ayırmamız yeterli olacaktır. Ancak ne olur ne olmaz diye fazladan girebilirsiniz. 1000 liralık girdiğinizde, 700 liranız dağıtımdan sonra geri hesabınıza aktarılır.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Tahmini Lot / Tutar Hesaplama',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Halka arzlara girmeden önce, eşit dağıtım yapılacak halka arzlarda size tahmini değerleri gösterir.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),


                    SizedBox(height: 10),


                    SizedBox(height: 10),




                    SizedBox(height: 20),
                    Text(
                      'Eşit Dağıtım Halka Arz',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Halka arz olan hisseler oransal veya eşit dağıtım yapabilir. Borsada bazen bir trend olarak dağıtım yapıldığı da olur.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Dağıtım Şekilleri:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '1- Oransal Dağıtım: İzahnameye göre yatırımcılara oransal olarak hisse dağıtımı yapılır.',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '2- Eşit Dağıtım: Dağıtılacak lot sayısı halka arza katılan katılımcılar arasında eşit olarak dağıtılır. Eşit dağıtım yapılacaksa, hisse aşağıda ki araç tam size göre.',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Halka arz olan hisse eşit dağıtım demesine rağmen bazen eşit dağıtım yapılmayabilir. Ancak bu fark genellikle çok küçüktür. Eğer dağıtılacak lot sayısı katılımcılar arasında eşit bölüştürülmezse, ilk katılanlar avantajlıdır. Bu fark genellikle 1 lot civarındadır ve mecburiyetten doğar.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Hesaplama ile ilgili daha fazla soru için iletişim bölümünden bizimle iletişime geçebilirsiniz. Halka arz hisseleri ve daha fazlası için Instagram sayfamızı takip edebilirsiniz. Bu metinlerden ilham alarak bilgilendirmeler yapabilirsiniz.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],

                ))

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
