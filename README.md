![egsoz-ekzoz-egzos-eksoz-eksoz](https://github.com/metwse/rofi-tdk.sh/assets/108795071/bcc2a3ae-e182-4b4c-90a7-2053123c655d)

<video src='https://github.com/metwse/rofi-tdk.sh/assets/108795071/17c70710-9157-439f-bbf8-3c3db42fc87b'></video>

# rofi-tdk.sh 
Türkçe sözlüğe direkt Rofi'den erişin.\
Veriler [sozluk.gov.tr](https://sozluk.gov.tr/)'den aynen alınmıştır. Hatalı (bağlaç öbeği, bağlaç grubu, … geçmişi (olmak) gibi), anlamsız (111www4sa, 113jhhgffpppp gibi) kelimeler ve yazım hatası bulunduran (din \[2\] gibi) maddeler; orijinal sözlükte de özdeştir. Türkçe sözlüğün ham verileri için [tdk-sozluk.git](https://github.com/metwse/tdk-sozluk)'e bakabilirsiniz.

## Kurulum 
1. [Releases](https://github.com/metwse/rofi-tdk.sh/releases) sayfasından veri tabanının son versiyonunu indirin ve `/var/rofi-tdk.tar.gz` konumuna kaydedin. ([direkt bağlantı](https://github.com/metwse/rofi-tdk.sh/releases/latest/download/rofi-tdk.tar.gz))
2. `rofi-tdk.sh` dosyasını başlatın.
3. (Opsiyonel) i3wm ya da benzeri bir pencere yöneticisi kullanıyorsanız i3 config'inize `exec /bilmemneresi/rofi-tdk.sh init` ekleyebilirsiniz.

## Kullanım
Kelimede düzeltme işareti (â, û, î) olduğunda aramada düzeltme işareti kullanmazsanız istediğiniz kelime listede aşağıda kalır. X11'de â, û ve î; altgr ile (altgr-a gibi) yazılabilir. Örneğim mekân kelimesini mekan şeklinde aratırsanız uygun sonuç için aşağı inmeniz gerekecektir.\
**Anlam menüsünde**:\
ESC: Arama menüsüne döner.\
Eğer uzun olduğu için görünmeyen bir madde varsa onu seçerek büyütebilirsiniz.\
*Bakınız* (Kullanılması tavsiye edilen kelimeyi ifade eder.) ya da ► işaretiyle (Eş ya da yakın anlamlılık belirtir.) başlayan maddeler, seçildiğinde ilgili kelimeye yönlendirir.

## Ayarlamalar
Veri tabanını varsayılandan başka bir konuma kaydetmek istiyorsanız `DATABASE` ortam değişkenini kullanabilirsiniz.\
Örneğin `DATABASE="~/.local/share/rofi-tdk.tar.gz" rofi-tdk.sh`

`rofi-tdk.sh`, açılışında `CACHE` ortam değişkeninin belirttiği konumda bir klasörün olup olmadığını kontrol eder. Böyle bir klasör yoksa `$CACHE` konumuna klasör açıp veri tabanını kaydeder. Bu sayede `rofi-tdk.tar.gz`yi arşivden defalarca çıkarmamış olur. Varsayılan ayarlarda `CACHE`, `/dev/shm`yi belirtir. `/dev/shm`, pek çok Linux dağıtımında olan, dosyaların RAM'de tutulduğu sanal disktir. RAM'in kullanılmasını istemiyorsanız `CACHE`yi `/tmp/rofi-tdk-cache`ye, bilgisayarın açıldığında `tar.gz` arşivinin tekrar tekrar açılmasını istemiyorsanız da `CACHE`yi kalıcı depolamaya ayarlayabilirsiniz.
```
CACHE=~/.local/share/rofi-tdk-cache/ rofi-tdk.sh # yavaş bilgisayarlar için ideal. bu şekilde bir kere veri tabanını yükledikten sonra $DATABASE konumundaki arşivi silebilirsiniz.
CACHE=/tmp/rofi-tdk-cache/ rofi-tdk.sh # pek tavsiye etmem. veri tabanının boyutu yaklaşık 385MiB, diske yazmak vakit alabilir.
```

## Özelleştirmeler
Tema, renk vb. düzenlemeler için kaynak kodundaki `MARKUP` değişkenleri kullanılabilir.

## Gereksinimler
`sed`, `cut`, `head`, `tail`, `md5sum`, `mktemp` gibi temel GNU/Linux fonksiyonları, hemen hemen bütün dağıtımlarda yüklü gelir.\
`rofi` (v1.7'den öncesinde test edilmedi)
