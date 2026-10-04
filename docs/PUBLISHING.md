# ccBridger — Yayınlama Rehberi (Marketplace, Issue Analizi, Connector)

Bu doküman üç soruyu kapsar:

1. Claude Desktop'ta **"by ccbridger" → "by FXerkan"** nasıl düzeltilir.
2. Plugin'i **Claude Plugin Marketplace / Directory**'de yayınlamanın tüm adımları.
3. Bu aracın çözdüğü **GitHub talepleri** (#28795, #50642 ve benzerleri) ve bir **Connector** olarak eklenip eklenemeyeceği.

---

## 1. "by ccbridger" → "by FXerkan" düzeltmesi

### Neden "ccbridger" görünüyordu?

Directory listesindeki **"by X"** satırını plugin'in **`author.name`** alanı belirler. Bu çözülemediğinde (marketplace girişinde `author` yoksa veya index onu bağlayamadıysa) arayüz **plugin `name`**'ine düşer ve onu title-case yapar. Senin durumunda görünen "ccbridger" tam olarak bu fallback'ti — `author.name` (`fxerkan`) hiç okunmamış, `name` (`ccbridger`) gösterilmişti.

Not: `marketplace.json`'daki **`owner.name`** plugin yazarı DEĞİLDİR — o marketplace sahibidir. Resmî marketplace'te `owner` hep "Anthropic"tir ama her plugin kendi satıcısını (42Crunch, Adobe...) **per-entry `author.name`** üzerinden gösterir.

### Yapılan değişiklikler (bu repoda uygulandı)

- `.claude-plugin/plugin.json` → `author.name`: `"fxerkan"` → **`"FXerkan"`**
- `.claude-plugin/marketplace.json` → plugin girişine **`author` eklendi** (`FXerkan`); `owner.name` de `FXerkan` yapıldı.
  - ⚠️ Marketplace'in üst seviye `name` alanı **`fxerkan` olarak bırakıldı** — bu, kurulum slug'ıdır (`claude plugin install ccbridger@fxerkan`). Değiştirilirse README'deki kurulum komutları ve mevcut kullanıcıların kaynağı bozulur.

> **Görüntülenen ad = `author.name` birebir.** "fxerkan" yazarsan "by fxerkan" görünür. İstediğin kapitalizasyon neyse (`FXerkan`) onu yaz.

### Doğrulama

```bash
claude plugin validate ./            # "✔ Validation passed" (uyarısız)
```

Yerel CLI (v2.1.195) şu alanları "Unknown field … ignored at load time" diye uyarır: `icon`, `documentationUrl`, `supportUrl`, `privacyPolicyUrl`, `termsOfServiceUrl`. **Bu uyarılar beklenir ve zararsızdır** — bunlar yalnızca **Directory listesi** için okunan alanlardır; CLI yüklemede kullanmaz ama **portal Listing details adımı plugin.json'dan okur** (portal "Not set. Add `privacyPolicyUrl` to plugin.json" gibi uyarır). Bu yüzden hepsi manifest'te tutulur:

- `icon` → `./docs/assets/icon.png` (ayrıca `.claude-plugin/icon.png` konvansiyon kopyası da var)
- `documentationUrl` → README, `supportUrl` → Issues
- `privacyPolicyUrl` → `PRIVACY.md`, `termsOfServiceUrl` → `TERMS.md` (ikisi de repo kökünde oluşturuldu: yerel araç, veri toplamıyor; MIT as-is)

`claude plugin validate ./` bu alanlar için uyarı verir ama **passed** der — submission için doğru olan budur.

### Canlı listede ne zaman değişir?

Repoyu değiştirmek canlı katalogu **otomatik güncellemez**. Yeni sürüm portal üzerinden (webhook veya zamanlanmış güncelleme ile) yeniden yayınlanıp yeniden index'lenince `author.name` yeni değeri okunur. En hızlı yol: [claude.ai/directory/manage](https://claude.ai/directory/manage) → ccbridger → sürümü güncelle.

---

## 2. Marketplace'te yayınlama — tüm adımlar

### Önce kavram: iki ayrı sistem var

| | Ne | Nasıl girilir |
|---|---|---|
| **A. `/plugin` Discover sekmesi** (Claude Code) | Senin **kayıtlı marketplace'lerinin** birleşimi. | `claude plugin marketplace add fxerkan/ccbridger` — ama bu seni **curated kataloga sokmaz.** |
| **B. Anthropic Directory** (claude.ai + [claude.com/marketplace](https://claude.com/marketplace/plugins)) | Resmî, incelenmiş katalog. Ekran görüntündeki "Discover" bu. | **Portal üzerinden submission** (aşağıda). PR atmak işe yaramaz — otomatik kapatılır. |

Senin ekran görüntündeki liste **B**'dir. Hedef: oraya **plugin bundle** olarak submission.

### Ön koşullar (pre-submission checklist)

- ✅ **Zorunlu metadata:** `name`, `displayName`, `author.name`, `description`, `version` — hepsi mevcut.
- ✅ **README** ≥ 40 kelime (kod blokları hariç) — listenin uzun açıklaması olur. Mevcut.
- ✅ **LICENSE** / `license` alanı — `MIT` mevcut.
- ✅ **Icon:** `./docs/assets/icon.png` (512×512 PNG). İzinli formatlar PNG/JPEG/GIF/WebP/SVG; kare PNG güvenli seçim. `.ico` kullanma.
- ✅ **Boyut limitleri:** repo < 50 MiB arşiv / 256 MiB açılmış, < 10.000 öğe, plugin başına ≤ 512 dosya. Portal "39 files, 4.3MB, within the size limits" dedi — uygun. (Kullanılmayan hero görselleri daldan temizlendi.)
- ✅ **Yasaklılar:** symlink, git submodule, LFS pointer, `.DS_Store`, gömülü credential yok. Kök dizindeki `ccb`/`ccbridger` symlink'leri **kaldırıldı** (plugin `scripts/ccbridger`'ı doğrudan kullanıyor).
- ✅ Paid claude.ai planı (Pro/Max kendi hesabından; Team/Enterprise Owner/Directory rolüyle).

### Adım adım submission

1. `claude plugin validate ./` → temiz (yalnızca directory-field uyarıları).
2. [claude.ai/directory/manage](https://claude.ai/directory/manage) → **Submit new → Plugin bundle**.
3. Kaynak olarak `github.com/fxerkan/ccbridger` gir (+ opsiyonel branch/path) → **validate**.
4. **Listing details**'i gözden geçir (plugin.json + README'den gelir) — **"by FXerkan" burada doğru görünüyor mu kontrol et.**
5. Data-handling sorularını yanıtla, iletişim e-postasını doğrula, acknowledgement'ları kabul et.
6. Güncelleme yöntemini seç (GitHub webhook veya zamanlanmış kontrol) → **Submit**.
7. Anthropic her sürümü inceler (otomatik güvenlik taraması + review) ve sonra yayına alır.

### Portal doğrulama bulguları (triage)

> ⚠️ Portal **`main` dalını** izler. İlk denemede `main @ 4024e3e` (ikon/temizlik öncesi) tarandığı için fazladan bulgu çıktı. **Bu bölümdeki tüm düzeltmeler `docs/plugin-visuals` dalında yapıldı; en kritik adım bunları `main`'e taşıyıp (merge) portalda `Re-validate` demek.** Alternatif: submission'da "Plugin in a subfolder or on another branch?" ile bu dalı göster.

**Düzeltildi (temiz, araç bozulmadan):**

| Bulgu | Durum |
|---|---|
| **No icon** | ✅ `.claude-plugin/icon.png` (512×512 PNG, 15 KB) eklendi. Portal kuralı: 512–2048 px kare PNG/JPEG, < 2 MB, SVG/WebP kabul değil → uyar. ⚠️ İkon listeye **yalnızca ilk kaydet/submit anında** yazılır, sonradan değişmez — bu yüzden ilk submission'dan **önce** doğru olmalı. |
| **Symbolic link not checked** (2) | ✅ Kök dizindeki `ccb` / `ccbridger` symlink'leri kaldırıldı (plugin zaten `scripts/ccbridger`'ı kullanıyor; symlink'ler yalnız yerel kolaylıktı). |
| **Images/fonts** (12 → az) | ✅ Kullanılmayan hero görselleri (`hero-1..6`, `8`, `9`) daldan silindi; yalnız `hero-7`, `icon`, `og-image` kaldı. Kalanlar zararsız (kodda çalıştırılmıyor), "held for review" bilgilendirmesi. |
| Yerel `validate` uyarıları (3) | ✅ `icon`/`documentationUrl`/`supportUrl` alanları manifest'ten kaldırıldı → `validate` uyarısız. |

**Aracın doğası gereği — bırak ve review'da açıkla** (portal bunları *reddetmez*, "Policy hold = incelemeye alınır" der; "leaving as they are and waiting for the review is also fine"):

| Bulgu | Neden böyle / review notu |
|---|---|
| **Hook grants permission** (`PermissionRequest` → `allow`) | ccBridger'ın **tüm amacı** bu: izin promptunu telefona taşıyıp **kullanıcı "Approve"a bastıktan sonra** `behavior:"allow"` döndürür. Karar modele değil, **insana** aittir; hook yalnızca birebir "Approve" etiketini onay sayar. Matcher daraltmak işlevi bozar. **Değiştirme — review'da açıkla.** |
| **Uses a credential from the user's machine** (4) | Script credential **okumaz**; relay'i başlatırken `env -u ANTHROPIC_MODEL -u ANTHROPIC_BASE_URL -u AWS_BEARER_TOKEN_BEDROCK …` ile provider değişkenlerini **siler**. Bulgu, bu değişken adlarının geçmesinden kaynaklanan (yarı) false-positive. **Değiştirme — review'da açıkla.** |
| **Scripts the validator couldn't follow** (`scripts/ccbridger`) | Tek Python dosyası; `tmux`/`env`/`claude` alt süreçlerini çağırdığı için statik olarak izlenemiyor. npx/uvx/pip-install yok, literal yol kullanılıyor. **Review'da açıkla.** |
| **Download-and-run command** (2) | Yalnızca **dokümantasyonda** (README'deki `notify_cmd` curl örneği, `marketplace add`). Portal: "only in documentation → nothing needs to change." Aksiyon yok. |

> **Review'a kısa not örneği (submission'ın açıklama alanına):** "ccBridger is a remote-approval bridge: the PermissionRequest hook returns `allow` only after the human explicitly taps *Approve* in the Claude mobile app (the model never decides; only the exact *Approve* label counts). The script does not read credentials — it strips provider env vars (`env -u …`) when launching the relay. No network listener, state is local files under `~/.claude/ccbridger/` (mode 0700)."

### "Anthropic verified" rozeti

Self-service değil; Anthropic resmî/partner plugin'lere uygular. Manifest'te bunu açan bir alan yok.

### Beklenti: nerede çalışır

Hooks, **claude.ai web'de çalışmaz** ("Ignored"), yalnızca Claude Code (ve Cowork) üzerinde çalışır. ccBridger'ın tüm mantığı hooks + yerel relay olduğundan: **liste** her yerde görünür (ikon + by-line + arama), ama **işlev** Claude Code'da çalışır — ki zaten oraya ait. Pakete dahil `ccb` **skill**'i tüm yüzeylerde yüklenir, bu da listeyi claude.ai'de "canlı" tutar.

---

## 3. Çözdüğü GitHub talepleri

### Hedef issue'lar

**#28795 — Support AWS Bedrock + AWS SSO in `claude remote-control`** (AÇIK, **131 reaction**, 13 yorum) — amiral gemisi talep.
- İstenen: `CLAUDE_CODE_USE_BEDROCK=1` + AWS SSO ile çalışan kurumsal kullanıcılar, ayrı claude.ai aboneliği olmadan Remote Control'ü AWS STS/Bedrock üzerinden doğrulayıp mobilden yönetmek istiyor. Yorumlar Vertex'e, "dual-wield" (kurumsal + kişisel login) senaryosuna ve SSH remote'a genişliyor.
- **Verdict: KISMEN çözer (güçlü pratik uyum, farklı mekanizma).** ccBridger istenen günlük yeteneği (Bedrock oturumunu mobilden onayla/yanıtla/mesajla) hooks + relay ile verir. **Boşluklar:** (a) native decoupled-auth değil, sidecar; (b) abonelik gereksinimini kaldırmaz, makinedeki ikinci bir "dual-wield" claude.ai login'ine taşır; (c) Bedrock SSH remote engine (SigV4 forwarding) kapsam dışı. Birkaç yorumcu Cursor/Codex'in bunu native yaptığını belirtiyor — ccBridger ürünü değiştirmez.

**#50642 — Remote Control should support AWS Bedrock authentication** (KAPALI, #28795'in duplicate'i, 0 reaction).
- Aynı talep, sandboxed EC2/VPC CDE çerçevesinde. **Verdict: KISMEN.** Ek boşluk: sandbox/VPC'de yerel claude.ai login + tmux relay + Claude app'e outbound erişim zor/politika-engelli olabilir. O ortamda gerçekçi uyum: `relay:false` + `notify_cmd` (ntfy/Slack/pager, `ccb ok/no` ile SSH üzerinden) — izleme+uzaktan onayı çözer ama "telefonda Claude app içinde" deneyimini vermez.

### Talep sıralaması (Medium yazısı için — demand'e göre)

| # | Issue | Durum | Sinyal | ccBridger |
|---|---|---|---|---|
| 1 | **#28795** Bedrock + AWS SSO remote-control | AÇIK | **131 reaction** | Kısmen (amiral gemisi, sidecar≠native) |
| 2 | **#35637** Permission prompt'ları mobilde render olmuyor | AÇIK | 30 reaction, 23 yorum | Semptomu çözer (API-provider oturumlarında native Approve/Reject) |
| 3 | **#28508** Mobildeki AskUserQuestion cevabı CLI'a dönmüyor | AÇIK | 27 reaction, 19 yorum | Semptomu çözer (pozisyonla eşlenen cevap) |
| 4 | **#45942** Android "always allow" tool call'ları bozuyor | AÇIK | 16 reaction | Komşu (kendi kanalı bu hatadan kaçınır, düzeltmez) |
| 5 | **#63924** `/clear` remote cihazdan çalışmıyor | AÇIK | 13 reaction | Çözmez (aynı sınır: mesajlar metin olarak gider) |
| 6 | **#90606** Permission dialog host terminalde asılı kalıyor | AÇIK | düşük ama birebir | Çözer (amiral gemisi özelliği: 15sn sonra telefonda) |
| 7 | **#95744** Tek oturumda non-Anthropic provider + Remote Control | AÇIK | yeni/düşük | ccBridger'ın mimari tezi (iki süreçle böler) |
| 8 | **#50642** Bedrock auth for Remote Control | KAPALI (dup) | — | Talebin tekrarladığının kanıtı; VPC fallback değeri |

Ayrıca **#81546** (eligibility'nin mimari mi preview mi olduğunu belgeler): üç-provider boşluğunu ve **ZDR/compliance** sınırını teyit eder — ccBridger orada yardımcı olmaz (relay prompt metnini Claude app'e gönderir).

### Yazı için dürüstlük notları (boşluklar)

- **Aboneliği kaldırmaz**, makinedeki ikinci login'e taşır. Tek gerçekten abonelik-siz yol `relay:false` + `notify_cmd`'dir ve "Claude app içinde" deneyimini bırakır.
- **Native değil, ürün düzeltmesi değil** — paralel sidecar; Claude Code'u değiştirmez.
- **Windows yok** — macOS/Linux + tmux. (#45942 WSL, win32 talepleri karşılanmaz.)
- **ZDR/compliance** kapsam dışı.
- **Vertex/Foundry** kod yolu destekli ama uçtan uca test edilmemiş; gerçek talep zaten Bedrock'ta.

**Özet:** ccBridger bu talepleri requester'ların kastettiği anlamda (native, abonelik-siz, cross-platform, Claude Code'a gömülü) **tam çözmez**; ama çekirdek kümeyi (#28795, #90606, #35637, #28508, #95744) **kısmen ama çok pratik** biçimde çözer — Bedrock/Vertex/Foundry oturumlarını telefondan onayla/yanıtla/mesajla, bedeli makinede bir claude.ai login'i ve Windows/ZDR/login-siz kurulumların dışarıda kalması.

---

## 4. Connector olarak eklenebilir mi?

### Kısa cevap: HAYIR — ve gerek de yok.

**Connector = uzaktan, internette host edilen HTTPS MCP sunucusu** (Google Drive, Notion, Slack gibi). ccBridger ise **yerel, sunucusuz, hook tabanlı** bir araç: tek Python dosyası, ağda hiçbir şey dinlemiyor, `~/.claude/ccbridger/` altında düz dosyalar, tmux relay. Tanım gereği uygun değil.

### Neden uygun değil

Connector gereksinimleri: host edilmiş HTTPS endpoint + Streamable HTTP transport + (hesap üstünde işlem varsa) OAuth 2.0 + tool annotation'ları + reviewer için canlı test hesabı. Submission: [claude.ai/directory/manage](https://claude.ai/directory/manage) → "MCP connector". ccBridger'da bu primitiflerin **hiçbiri** yok; mimarisi tam tersi.

### Yeniden mimarlemek mantıklı mı? Hayır.

Connector olmak için ccBridger'ın kasıtla kaçındığı her şeyi kurman gerekir: host edilmiş MCP sunucusu + OAuth + hesap sistemi + bulutta oturum state'i. Üstelik uzaktaki bir sunucu kullanıcının yerel terminaline zaten makinede çalışan bir ajan olmadan uzanamaz — yani yerel parça yine lazım. Kazanç: bir connector listesi. Kayıp: sıfır hosting, sıfır hesap, sıfır açık port, "ağda hiçbir şey dinlemiyor" güvenlik hikâyesi, "tek Python dosyası" sadeliği. **Değmez.** Yerel-hook tasarımı ürünün ta kendisi.

### "Kendi ikonu + kolay aranabilir + keşfedilebilir" hedefi için doğru yol

Bu hedef **Connector değil, Directory'ye plugin olarak submission** ile zaten karşılanıyor — ikon + "by FXerkan" + arama + Claude app'te görünürlük. Yani bu dokümanın **2. bölümü** istediğin görünürlüğü veren tek aksiyon.

### Üç kovayı netleştirelim

| Kova | Nedir | Hosting/hesap | Nerede görünür | ccBridger bu mu? |
|---|---|---|---|---|
| **Claude Code Plugin** | hooks/skill/command/agent paketi (GitHub repo) | Yok (kullanıcının makinesinde) | Directory + `/plugin` Discover; **kendi ikonu, aranabilir** | **EVET** |
| **Connector** | uzaktan host edilmiş HTTPS MCP + OAuth | Sen host edersin + auth sistemi | Settings → Connectors → Discover | Hayır (sunucu yok) |
| **Yerel MCP server** | makinede stdio MCP tool sunan süreç | Yok ama süreç var | Claude Code/Cowork; claude.ai'de yok sayılır | Hayır (MCP tool değil, hook kullanır) |

---

## Kaynaklar

- [Publish a plugin](https://code.claude.com/docs/en/plugins/publish) · [Submit a plugin](https://claude.com/docs/plugins/submit) · [Pre-submission checklist](https://claude.com/docs/plugins/pre-submission-checklist)
- [Plugin manifest reference](https://code.claude.com/docs/en/plugins-reference) · [Marketplace reference](https://code.claude.com/docs/en/plugins/marketplace-reference)
- [Anthropic's marketplaces](https://code.claude.com/docs/en/plugins/anthropic-marketplaces) · [Platform support](https://claude.com/docs/plugins/platform-support)
- [Submit a connector](https://claude.com/docs/connectors/building/submission) · [Publish to the directory](https://claude.com/docs/directory/publish)
- Issue'lar: [#28795](https://github.com/anthropics/claude-code/issues/28795) · [#50642](https://github.com/anthropics/claude-code/issues/50642) · [#35637](https://github.com/anthropics/claude-code/issues/35637) · [#28508](https://github.com/anthropics/claude-code/issues/28508) · [#90606](https://github.com/anthropics/claude-code/issues/90606) · [#95744](https://github.com/anthropics/claude-code/issues/95744) · [#81546](https://github.com/anthropics/claude-code/issues/81546)
