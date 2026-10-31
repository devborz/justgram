// Justgram
import Foundation
import TelegramPresentationData

/// Text of the Justgram settings screen in one interface language.
struct JustgramTranslation {
    let off: String
    let inactiveHeader: String
    let inactiveFooter: String
    let hideUnread: String
    let hideUnreadFooter: String
    let hideChannels: String
    let hideChannelsFooter: String
    let calmHeader: String
    let grayscale: String
    /// %1$@ is Power Saving, %2$@ Large Emoji, %3$@ Appearance, in the words of the active language pack.
    let calmFooterFormat: String
    let appIconPhone: String
    let appIconFeather: String
    let appIconWeight: String
}

/// Telegram's language packs come from its servers and never carry Justgram's keys, so every interface
/// language has its own table here; anything else falls back to English. Day counts and the names of
/// Telegram's own settings are read from the active pack, so they always match its screens.
@dynamicMemberLookup
struct JustgramStrings {
    private let strings: PresentationStrings
    private let translation: JustgramTranslation

    init(strings: PresentationStrings) {
        self.strings = strings
        self.translation = justgramTranslation(languageCode: strings.baseLanguageCode)
    }

    subscript(dynamicMember keyPath: KeyPath<JustgramTranslation, String>) -> String {
        return self.translation[keyPath: keyPath]
    }

    func days(_ value: Int32) -> String {
        if value == 0 {
            return self.translation.off
        }
        return self.strings.MessageTimer_Days(value)
    }

    var calmFooter: String {
        return String(format: self.translation.calmFooterFormat, self.strings.Settings_PowerSaving, self.strings.Appearance_LargeEmoji, self.strings.Settings_Appearance)
    }
}

private func justgramTranslation(languageCode: String) -> JustgramTranslation {
    var code = languageCode.lowercased()
    if code.hasSuffix("-raw") {
        code = String(code.dropLast("-raw".count))
    }
    if let translation = justgramTranslations[code] {
        return translation
    }
    if let base = code.split(whereSeparator: { $0 == "-" || $0 == "_" }).first, let translation = justgramTranslations[String(base)] {
        return translation
    }
    return justgramEnglish
}

private let justgramEnglish = JustgramTranslation(
    off: "Off",
    inactiveHeader: "HIDE INACTIVE CHATS",
    inactiveFooter: "Chats without new messages for longer than this are hidden from the list. Pinned chats always stay. Use Search to find a hidden chat; a new message brings it back.",
    hideUnread: "Hide Unread Chats Too",
    hideUnreadFooter: "When off, an inactive unmuted chat with unread messages stays in the list until you read it.",
    hideChannels: "Hide Channels",
    hideChannelsFooter: "Channels are removed from the chat list and the badge. You can still find them in Search.",
    calmHeader: "CALM INTERFACE",
    grayscale: "Grayscale",
    calmFooterFormat: "The whole interface turns grayscale. GIF and video autoplay are set in %1$@, %2$@ in %3$@.",
    appIconPhone: "Phone",
    appIconFeather: "Feather",
    appIconWeight: "Weight"
)

// Keyed by the official Telegram interface languages (Settings ▸ Language).
private let justgramTranslations: [String: JustgramTranslation] = [
    "en": justgramEnglish,
    "ru": JustgramTranslation(
        off: "Не скрывать",
        inactiveHeader: "СКРЫВАТЬ НЕАКТИВНЫЕ ЧАТЫ",
        inactiveFooter: "Чаты без новых сообщений дольше этого срока исчезают из списка. Закреплённые чаты не скрываются. Скрытый чат можно найти через поиск, а новое сообщение вернёт его в список.",
        hideUnread: "Скрывать и непрочитанные",
        hideUnreadFooter: "Если выключено, неактивный незаглушённый чат с непрочитанными сообщениями остаётся в списке, пока вы его не прочитаете.",
        hideChannels: "Скрывать каналы",
        hideChannelsFooter: "Каналы пропадают из списка чатов и не учитываются в счётчике. Найти их можно через поиск.",
        calmHeader: "СПОКОЙНЫЙ ИНТЕРФЕЙС",
        grayscale: "Чёрно-белый режим",
        calmFooterFormat: "Весь интерфейс становится чёрно-белым. Автовоспроизведение GIF и видео настраивается в разделе «%1$@», «%2$@» — в разделе «%3$@».",
        appIconPhone: "Телефон",
        appIconFeather: "Перо",
        appIconWeight: "Гирька"
    ),
    "uk": JustgramTranslation(
        off: "Не приховувати",
        inactiveHeader: "ПРИХОВУВАТИ НЕАКТИВНІ ЧАТИ",
        inactiveFooter: "Чати без нових повідомлень довше за цей строк зникають зі списку. Закріплені чати не приховуються. Прихований чат можна знайти через пошук, а нове повідомлення поверне його до списку.",
        hideUnread: "Приховувати й непрочитані",
        hideUnreadFooter: "Якщо вимкнено, неактивний чат з увімкненими сповіщеннями й непрочитаними повідомленнями залишається в списку, доки ви його не прочитаєте.",
        hideChannels: "Приховувати канали",
        hideChannelsFooter: "Канали зникають зі списку чатів і не враховуються в лічильнику. Знайти їх можна через пошук.",
        calmHeader: "СПОКІЙНИЙ ІНТЕРФЕЙС",
        grayscale: "Чорно-білий режим",
        calmFooterFormat: "Увесь інтерфейс стає чорно-білим. Автовідтворення GIF і відео налаштовується в розділі «%1$@», «%2$@» — у розділі «%3$@».",
        appIconPhone: "Телефон",
        appIconFeather: "Перо",
        appIconWeight: "Гирька"
    ),
    "be": JustgramTranslation(
        off: "Не хаваць",
        inactiveHeader: "ХАВАЦЬ НЕАКТЫЎНЫЯ ЧАТЫ",
        inactiveFooter: "Чаты без новых паведамленняў даўжэй за гэты тэрмін знікаюць са спіса. Замацаваныя чаты не хаваюцца. Схаваны чат можна знайсці праз пошук, а новае паведамленне верне яго ў спіс.",
        hideUnread: "Хаваць і непрачытаныя",
        hideUnreadFooter: "Калі выключана, неактыўны чат з уключанымі апавяшчэннямі і непрачытанымі паведамленнямі застаецца ў спісе, пакуль вы яго не прачытаеце.",
        hideChannels: "Хаваць каналы",
        hideChannelsFooter: "Каналы знікаюць са спіса чатаў і не ўлічваюцца ў лічыльніку. Знайсці іх можна праз пошук.",
        calmHeader: "СПАКОЙНЫ ІНТЭРФЕЙС",
        grayscale: "Чорна-белы рэжым",
        calmFooterFormat: "Увесь інтэрфейс становіцца чорна-белым. Аўтапрайграванне GIF і відэа наладжваецца ў раздзеле «%1$@», «%2$@» — у раздзеле «%3$@».",
        appIconPhone: "Тэлефон",
        appIconFeather: "Пяро",
        appIconWeight: "Гірка"
    ),
    "kk": JustgramTranslation(
        off: "Жасырмау",
        inactiveHeader: "БЕЛСЕНДІ ЕМЕС ЧАТТАРДЫ ЖАСЫРУ",
        inactiveFooter: "Осы мерзімнен ұзақ жаңа хабарламасы жоқ чаттар тізімнен жасырылады. Бекітілген чаттар жасырылмайды. Жасырын чатты іздеу арқылы табуға болады, ал жаңа хабарлама оны тізімге қайтарады.",
        hideUnread: "Оқылмағандарды да жасыру",
        hideUnreadFooter: "Өшірулі болса, хабарландырулары қосулы, оқылмаған хабарламалары бар белсенді емес чат сіз оны оқығанша тізімде қалады.",
        hideChannels: "Арналарды жасыру",
        hideChannelsFooter: "Арналар чаттар тізімінен жойылады және санауышқа кірмейді. Оларды іздеу арқылы табуға болады.",
        calmHeader: "ТЫНЫШ ИНТЕРФЕЙС",
        grayscale: "Ақ-қара режим",
        calmFooterFormat: "Бүкіл интерфейс ақ-қара болады. GIF пен бейнелерді автоойнату «%1$@» бөлімінде, «%2$@» — «%3$@» бөлімінде бапталады.",
        appIconPhone: "Телефон",
        appIconFeather: "Қауырсын",
        appIconWeight: "Гір"
    ),
    "sr": JustgramTranslation(
        off: "Не скривај",
        inactiveHeader: "СКРИВАЈ НЕАКТИВНА ЋАСКАЊА",
        inactiveFooter: "Ћаскања без нових порука дуже од овог рока нестају са листе. Закачена ћаскања се не скривају. Скривено ћаскање можете пронаћи претрагом, а нова порука га враћа на листу.",
        hideUnread: "Скривај и непрочитана",
        hideUnreadFooter: "Када је искључено, неактивно ћаскање са укљученим обавештењима и непрочитаним порукама остаје на листи док га не прочитате.",
        hideChannels: "Скривај канале",
        hideChannelsFooter: "Канали нестају са листе ћаскања и не урачунавају се у бројач. Можете их пронаћи претрагом.",
        calmHeader: "МИРАН ИНТЕРФЕЈС",
        grayscale: "Црно-бели режим",
        calmFooterFormat: "Цео интерфејс постаје црно-бео. Аутоматско пуштање GIF-ова и видео-снимака подешава се у одељку „%1$@“, а „%2$@“ у одељку „%3$@“.",
        appIconPhone: "Телефон",
        appIconFeather: "Перо",
        appIconWeight: "Тег"
    ),
    "hr": JustgramTranslation(
        off: "Ne skrivaj",
        inactiveHeader: "SKRIVAJ NEAKTIVNE RAZGOVORE",
        inactiveFooter: "Razgovori bez novih poruka dulje od ovog razdoblja nestaju s popisa. Prikvačeni razgovori se ne skrivaju. Skriveni razgovor možete pronaći pretraživanjem, a nova poruka vraća ga na popis.",
        hideUnread: "Skrivaj i nepročitane",
        hideUnreadFooter: "Kad je isključeno, neaktivan razgovor s uključenim obavijestima i nepročitanim porukama ostaje na popisu dok ga ne pročitate.",
        hideChannels: "Skrivaj kanale",
        hideChannelsFooter: "Kanali nestaju s popisa razgovora i ne ubrajaju se u brojač. I dalje ih možete pronaći pretraživanjem.",
        calmHeader: "MIRNO SUČELJE",
        grayscale: "Crno-bijeli način",
        calmFooterFormat: "Cijelo sučelje postaje crno-bijelo. Automatska reprodukcija GIF-ova i videozapisa podešava se u odjeljku „%1$@”, a „%2$@” u odjeljku „%3$@”.",
        appIconPhone: "Telefon",
        appIconFeather: "Pero",
        appIconWeight: "Uteg"
    ),
    "cs": JustgramTranslation(
        off: "Neskrývat",
        inactiveHeader: "SKRÝVAT NEAKTIVNÍ CHATY",
        inactiveFooter: "Chaty bez nových zpráv déle než tuto dobu zmizí ze seznamu. Připnuté chaty se neskrývají. Skrytý chat najdete pomocí hledání a nová zpráva ho vrátí do seznamu.",
        hideUnread: "Skrývat i nepřečtené",
        hideUnreadFooter: "Když je vypnuto, neaktivní chat se zapnutými oznámeními a nepřečtenými zprávami zůstane v seznamu, dokud ho nepřečtete.",
        hideChannels: "Skrývat kanály",
        hideChannelsFooter: "Kanály zmizí ze seznamu chatů a nezapočítávají se do odznaku. Najdete je pomocí hledání.",
        calmHeader: "KLIDNÉ ROZHRANÍ",
        grayscale: "Černobílý režim",
        calmFooterFormat: "Celé rozhraní bude černobílé. Automatické přehrávání GIFů a videí se nastavuje v sekci „%1$@“, „%2$@“ v sekci „%3$@“.",
        appIconPhone: "Telefon",
        appIconFeather: "Pero",
        appIconWeight: "Závaží"
    ),
    "sk": JustgramTranslation(
        off: "Neskrývať",
        inactiveHeader: "SKRÝVAŤ NEAKTÍVNE ČETY",
        inactiveFooter: "Čety bez nových správ dlhšie ako tento čas zmiznú zo zoznamu. Pripnuté čety sa neskrývajú. Skrytý čet nájdete cez vyhľadávanie a nová správa ho vráti do zoznamu.",
        hideUnread: "Skrývať aj neprečítané",
        hideUnreadFooter: "Keď je vypnuté, neaktívny čet so zapnutými upozorneniami a neprečítanými správami zostane v zozname, kým ho neprečítate.",
        hideChannels: "Skrývať kanály",
        hideChannelsFooter: "Kanály zmiznú zo zoznamu četov a nezapočítavajú sa do odznaku. Nájdete ich cez vyhľadávanie.",
        calmHeader: "POKOJNÉ ROZHRANIE",
        grayscale: "Čiernobiely režim",
        calmFooterFormat: "Celé rozhranie bude čiernobiele. Automatické prehrávanie GIFov a videí sa nastavuje v sekcii „%1$@“, „%2$@“ v sekcii „%3$@“.",
        appIconPhone: "Telefón",
        appIconFeather: "Pero",
        appIconWeight: "Závažie"
    ),
    "pl": JustgramTranslation(
        off: "Nie ukrywaj",
        inactiveHeader: "UKRYWAJ NIEAKTYWNE CZATY",
        inactiveFooter: "Czaty bez nowych wiadomości dłużej niż ten czas znikają z listy. Przypięte czaty nie są ukrywane. Ukryty czat znajdziesz przez wyszukiwanie, a nowa wiadomość przywróci go na listę.",
        hideUnread: "Ukrywaj też nieprzeczytane",
        hideUnreadFooter: "Gdy wyłączone, nieaktywny czat z włączonymi powiadomieniami i nieprzeczytanymi wiadomościami pozostaje na liście, dopóki go nie przeczytasz.",
        hideChannels: "Ukrywaj kanały",
        hideChannelsFooter: "Kanały znikają z listy czatów i nie są wliczane do licznika. Nadal znajdziesz je przez wyszukiwanie.",
        calmHeader: "SPOKOJNY INTERFEJS",
        grayscale: "Tryb czarno-biały",
        calmFooterFormat: "Cały interfejs staje się czarno-biały. Autoodtwarzanie GIF-ów i filmów ustawisz w sekcji „%1$@”, a „%2$@” w sekcji „%3$@”.",
        appIconPhone: "Telefon",
        appIconFeather: "Pióro",
        appIconWeight: "Odważnik"
    ),
    "de": JustgramTranslation(
        off: "Aus",
        inactiveHeader: "INAKTIVE CHATS AUSBLENDEN",
        inactiveFooter: "Chats, in denen länger als diesen Zeitraum keine neue Nachricht kam, werden aus der Liste ausgeblendet. Angeheftete Chats bleiben immer. Ausgeblendete Chats findest du über die Suche; eine neue Nachricht holt den Chat zurück.",
        hideUnread: "Auch ungelesene ausblenden",
        hideUnreadFooter: "Wenn aus, bleibt ein inaktiver, nicht stummgeschalteter Chat mit ungelesenen Nachrichten in der Liste, bis du ihn liest.",
        hideChannels: "Kanäle ausblenden",
        hideChannelsFooter: "Kanäle verschwinden aus der Chatliste und dem Zähler. Über die Suche findest du sie weiterhin.",
        calmHeader: "RUHIGE OBERFLÄCHE",
        grayscale: "Graustufen",
        calmFooterFormat: "Die gesamte Oberfläche wird in Graustufen angezeigt. Die automatische Wiedergabe von GIFs und Videos stellst du unter „%1$@“ ein, „%2$@“ unter „%3$@“.",
        appIconPhone: "Telefon",
        appIconFeather: "Feder",
        appIconWeight: "Gewicht"
    ),
    "fr": JustgramTranslation(
        off: "Désactivé",
        inactiveHeader: "MASQUER LES DISCUSSIONS INACTIVES",
        inactiveFooter: "Les discussions sans nouveau message depuis plus longtemps que cette durée sont masquées de la liste. Les discussions épinglées restent toujours. Utilisez la recherche pour retrouver une discussion masquée ; un nouveau message la fait réapparaître.",
        hideUnread: "Masquer aussi les non lues",
        hideUnreadFooter: "Si désactivé, une discussion inactive non mise en sourdine avec des messages non lus reste dans la liste jusqu'à ce que vous la lisiez.",
        hideChannels: "Masquer les chaînes",
        hideChannelsFooter: "Les chaînes disparaissent de la liste des discussions et du badge. Vous pouvez toujours les trouver via la recherche.",
        calmHeader: "INTERFACE APAISÉE",
        grayscale: "Niveaux de gris",
        calmFooterFormat: "Toute l'interface passe en niveaux de gris. La lecture automatique des GIF et des vidéos se règle dans « %1$@ », et « %2$@ » dans « %3$@ ».",
        appIconPhone: "Téléphone",
        appIconFeather: "Plume",
        appIconWeight: "Poids"
    ),
    "es": JustgramTranslation(
        off: "Desactivado",
        inactiveHeader: "OCULTAR CHATS INACTIVOS",
        inactiveFooter: "Los chats sin mensajes nuevos durante más tiempo que este se ocultan de la lista. Los chats fijados siempre se quedan. Usa la búsqueda para encontrar un chat oculto; un mensaje nuevo lo devuelve a la lista.",
        hideUnread: "Ocultar también los no leídos",
        hideUnreadFooter: "Si está desactivado, un chat inactivo no silenciado con mensajes no leídos permanece en la lista hasta que lo leas.",
        hideChannels: "Ocultar canales",
        hideChannelsFooter: "Los canales desaparecen de la lista de chats y del contador. Puedes encontrarlos en la búsqueda.",
        calmHeader: "INTERFAZ TRANQUILA",
        grayscale: "Escala de grises",
        calmFooterFormat: "Toda la interfaz pasa a escala de grises. La reproducción automática de GIF y videos se ajusta en «%1$@», y «%2$@» en «%3$@».",
        appIconPhone: "Teléfono",
        appIconFeather: "Pluma",
        appIconWeight: "Pesa"
    ),
    "ca": JustgramTranslation(
        off: "Desactivat",
        inactiveHeader: "AMAGA ELS XATS INACTIUS",
        inactiveFooter: "Els xats sense missatges nous durant més temps que aquest s'amaguen de la llista. Els xats fixats sempre s'hi queden. Fes servir la cerca per trobar un xat amagat; un missatge nou el torna a la llista.",
        hideUnread: "Amaga també els no llegits",
        hideUnreadFooter: "Si està desactivat, un xat inactiu no silenciat amb missatges no llegits es queda a la llista fins que el llegeixis.",
        hideChannels: "Amaga els canals",
        hideChannelsFooter: "Els canals desapareixen de la llista de xats i del comptador. Encara els pots trobar amb la cerca.",
        calmHeader: "INTERFÍCIE TRANQUIL·LA",
        grayscale: "Escala de grisos",
        calmFooterFormat: "Tota la interfície passa a escala de grisos. La reproducció automàtica de GIF i vídeos es configura a «%1$@», i «%2$@» a «%3$@».",
        appIconPhone: "Telèfon",
        appIconFeather: "Ploma",
        appIconWeight: "Pes"
    ),
    "it": JustgramTranslation(
        off: "Disattivato",
        inactiveHeader: "NASCONDI CHAT INATTIVE",
        inactiveFooter: "Le chat senza nuovi messaggi da più di questo periodo vengono nascoste dalla lista. Le chat fissate restano sempre. Usa la ricerca per trovare una chat nascosta; un nuovo messaggio la riporta nella lista.",
        hideUnread: "Nascondi anche le non lette",
        hideUnreadFooter: "Se disattivato, una chat inattiva non silenziata con messaggi non letti resta nella lista finché non la leggi.",
        hideChannels: "Nascondi canali",
        hideChannelsFooter: "I canali spariscono dalla lista delle chat e dal contatore. Puoi comunque trovarli con la ricerca.",
        calmHeader: "INTERFACCIA TRANQUILLA",
        grayscale: "Scala di grigi",
        calmFooterFormat: "L'intera interfaccia diventa in scala di grigi. La riproduzione automatica di GIF e video si imposta in «%1$@», e «%2$@» in «%3$@».",
        appIconPhone: "Telefono",
        appIconFeather: "Piuma",
        appIconWeight: "Peso"
    ),
    "pt": JustgramTranslation(
        off: "Desativado",
        inactiveHeader: "OCULTAR CONVERSAS INATIVAS",
        inactiveFooter: "Conversas sem novas mensagens por mais tempo que isso são ocultadas da lista. Conversas fixadas sempre ficam. Use a busca para encontrar uma conversa oculta; uma nova mensagem a traz de volta.",
        hideUnread: "Ocultar também as não lidas",
        hideUnreadFooter: "Quando desativado, uma conversa inativa não silenciada com mensagens não lidas fica na lista até você lê-la.",
        hideChannels: "Ocultar canais",
        hideChannelsFooter: "Os canais somem da lista de conversas e do contador. Você ainda pode encontrá-los na busca.",
        calmHeader: "INTERFACE TRANQUILA",
        grayscale: "Escala de cinza",
        calmFooterFormat: "Toda a interface fica em escala de cinza. A reprodução automática de GIFs e vídeos é ajustada em “%1$@”, e “%2$@” em “%3$@”.",
        appIconPhone: "Telefone",
        appIconFeather: "Pena",
        appIconWeight: "Peso"
    ),
    "nl": JustgramTranslation(
        off: "Uit",
        inactiveHeader: "INACTIEVE CHATS VERBERGEN",
        inactiveFooter: "Chats zonder nieuwe berichten gedurende langer dan deze periode worden uit de lijst verborgen. Vastgezette chats blijven altijd staan. Gebruik Zoeken om een verborgen chat te vinden; een nieuw bericht brengt hem terug.",
        hideUnread: "Ook ongelezen verbergen",
        hideUnreadFooter: "Als dit uit staat, blijft een inactieve chat die niet gedempt is en ongelezen berichten heeft in de lijst totdat je hem leest.",
        hideChannels: "Kanalen verbergen",
        hideChannelsFooter: "Kanalen verdwijnen uit de chatlijst en de teller. Je kunt ze nog steeds vinden via Zoeken.",
        calmHeader: "RUSTIGE INTERFACE",
        grayscale: "Grijstinten",
        calmFooterFormat: "De hele interface wordt grijs. Automatisch afspelen van GIF's en video's stel je in bij ‘%1$@’, ‘%2$@’ bij ‘%3$@’.",
        appIconPhone: "Telefoon",
        appIconFeather: "Veer",
        appIconWeight: "Gewicht"
    ),
    "sv": JustgramTranslation(
        off: "Av",
        inactiveHeader: "DÖLJ INAKTIVA CHATTAR",
        inactiveFooter: "Chattar utan nya meddelanden längre än så döljs från listan. Fästa chattar ligger alltid kvar. Använd sökningen för att hitta en dold chatt; ett nytt meddelande tar tillbaka den.",
        hideUnread: "Dölj även olästa",
        hideUnreadFooter: "När det är av ligger en inaktiv chatt som inte är tystad och har olästa meddelanden kvar i listan tills du läser den.",
        hideChannels: "Dölj kanaler",
        hideChannelsFooter: "Kanaler försvinner från chattlistan och räknaren. Du hittar dem fortfarande via sökningen.",
        calmHeader: "LUGNT GRÄNSSNITT",
        grayscale: "Gråskala",
        calmFooterFormat: "Hela gränssnittet blir gråskaligt. Automatisk uppspelning av GIF och video ställs in under ”%1$@”, ”%2$@” under ”%3$@”.",
        appIconPhone: "Telefon",
        appIconFeather: "Fjäder",
        appIconWeight: "Vikt"
    ),
    "nb": JustgramTranslation(
        off: "Av",
        inactiveHeader: "SKJUL INAKTIVE SAMTALER",
        inactiveFooter: "Samtaler uten nye meldinger lenger enn dette skjules fra listen. Festede samtaler blir alltid værende. Bruk søk for å finne en skjult samtale; en ny melding henter den tilbake.",
        hideUnread: "Skjul også uleste",
        hideUnreadFooter: "Når dette er av, blir en inaktiv samtale som ikke er dempet og har uleste meldinger værende i listen til du leser den.",
        hideChannels: "Skjul kanaler",
        hideChannelsFooter: "Kanaler forsvinner fra samtalelisten og telleren. Du finner dem fortsatt via søk.",
        calmHeader: "ROLIG GRENSESNITT",
        grayscale: "Gråtoner",
        calmFooterFormat: "Hele grensesnittet blir i gråtoner. Automatisk avspilling av GIF og video stilles inn under «%1$@», «%2$@» under «%3$@».",
        appIconPhone: "Telefon",
        appIconFeather: "Fjær",
        appIconWeight: "Lodd"
    ),
    "fi": JustgramTranslation(
        off: "Pois",
        inactiveHeader: "PIILOTA EPÄAKTIIVISET KESKUSTELUT",
        inactiveFooter: "Keskustelut, joissa ei ole ollut uusia viestejä tätä pidempään, piilotetaan listalta. Kiinnitetyt keskustelut pysyvät aina. Löydät piilotetun keskustelun haulla; uusi viesti palauttaa sen listalle.",
        hideUnread: "Piilota myös lukemattomat",
        hideUnreadFooter: "Kun asetus on pois päältä, epäaktiivinen mykistämätön keskustelu, jossa on lukemattomia viestejä, pysyy listalla, kunnes luet sen.",
        hideChannels: "Piilota kanavat",
        hideChannelsFooter: "Kanavat poistuvat keskustelulistalta ja laskurista. Löydät ne edelleen haulla.",
        calmHeader: "RAUHALLINEN KÄYTTÖLIITTYMÄ",
        grayscale: "Harmaasävyt",
        calmFooterFormat: "Koko käyttöliittymä muuttuu harmaasävyiseksi. GIFien ja videoiden automaattinen toisto asetetaan kohdassa ”%1$@”, ”%2$@” kohdassa ”%3$@”.",
        appIconPhone: "Puhelin",
        appIconFeather: "Höyhen",
        appIconWeight: "Punnus"
    ),
    "hu": JustgramTranslation(
        off: "Ki",
        inactiveHeader: "INAKTÍV CSEVEGÉSEK ELREJTÉSE",
        inactiveFooter: "Az ennél hosszabb ideje új üzenet nélküli csevegések eltűnnek a listáról. A kitűzött csevegések mindig maradnak. Rejtett csevegést a keresővel találhatsz meg; egy új üzenet visszahozza a listába.",
        hideUnread: "Olvasatlanok elrejtése is",
        hideUnreadFooter: "Ha ki van kapcsolva, a nem némított, olvasatlan üzeneteket tartalmazó inaktív csevegés a listán marad, amíg el nem olvasod.",
        hideChannels: "Csatornák elrejtése",
        hideChannelsFooter: "A csatornák eltűnnek a csevegéslistáról és a számlálóból. A keresővel továbbra is megtalálhatod őket.",
        calmHeader: "NYUGODT FELÜLET",
        grayscale: "Szürkeárnyalat",
        calmFooterFormat: "A teljes felület szürkeárnyalatos lesz. A GIF-ek és videók automatikus lejátszása a(z) „%1$@” részben állítható, a(z) „%2$@” pedig a(z) „%3$@” részben.",
        appIconPhone: "Telefon",
        appIconFeather: "Toll",
        appIconWeight: "Súly"
    ),
    "ro": JustgramTranslation(
        off: "Dezactivat",
        inactiveHeader: "ASCUNDE CONVERSAȚIILE INACTIVE",
        inactiveFooter: "Conversațiile fără mesaje noi de mai mult timp decât atât sunt ascunse din listă. Conversațiile fixate rămân mereu. Folosește căutarea pentru a găsi o conversație ascunsă; un mesaj nou o readuce în listă.",
        hideUnread: "Ascunde și pe cele necitite",
        hideUnreadFooter: "Când este dezactivat, o conversație inactivă cu notificările pornite și mesaje necitite rămâne în listă până o citești.",
        hideChannels: "Ascunde canalele",
        hideChannelsFooter: "Canalele dispar din lista de conversații și din contor. Le poți găsi în continuare prin căutare.",
        calmHeader: "INTERFAȚĂ LINIȘTITĂ",
        grayscale: "Tonuri de gri",
        calmFooterFormat: "Întreaga interfață devine în tonuri de gri. Redarea automată a GIF-urilor și videoclipurilor se setează în „%1$@”, iar „%2$@” în „%3$@”.",
        appIconPhone: "Telefon",
        appIconFeather: "Pană",
        appIconWeight: "Greutate"
    ),
    "tr": JustgramTranslation(
        off: "Kapalı",
        inactiveHeader: "ETKİN OLMAYAN SOHBETLERİ GİZLE",
        inactiveFooter: "Bu süreden uzun süredir yeni mesaj gelmeyen sohbetler listeden gizlenir. Sabitlenmiş sohbetler her zaman kalır. Gizli bir sohbeti bulmak için aramayı kullanın; yeni bir mesaj onu listeye geri getirir.",
        hideUnread: "Okunmamışları da gizle",
        hideUnreadFooter: "Kapalıyken, sessize alınmamış ve okunmamış mesajları olan etkin olmayan bir sohbet, siz okuyana kadar listede kalır.",
        hideChannels: "Kanalları gizle",
        hideChannelsFooter: "Kanallar sohbet listesinden ve sayaçtan kaldırılır. Onları yine de aramayla bulabilirsiniz.",
        calmHeader: "SAKİN ARAYÜZ",
        grayscale: "Gri tonlama",
        calmFooterFormat: "Tüm arayüz gri tonlamalı olur. GIF ve videoların otomatik oynatılması “%1$@” bölümünden, “%2$@” ise “%3$@” bölümünden ayarlanır.",
        appIconPhone: "Telefon",
        appIconFeather: "Tüy",
        appIconWeight: "Ağırlık"
    ),
    "uz": JustgramTranslation(
        off: "Yashirmaslik",
        inactiveHeader: "NOFAOL CHATLARNI YASHIRISH",
        inactiveFooter: "Bundan uzoq vaqt yangi xabar kelmagan chatlar roʻyxatdan yashiriladi. Qadalgan chatlar yashirilmaydi. Yashirin chatni qidiruv orqali topish mumkin, yangi xabar esa uni roʻyxatga qaytaradi.",
        hideUnread: "Oʻqilmaganlarni ham yashirish",
        hideUnreadFooter: "Oʻchiq boʻlsa, bildirishnomalari yoqilgan va oʻqilmagan xabarlari bor nofaol chat siz uni oʻqimaguningizcha roʻyxatda qoladi.",
        hideChannels: "Kanallarni yashirish",
        hideChannelsFooter: "Kanallar chatlar roʻyxatidan va hisoblagichdan olib tashlanadi. Ularni qidiruv orqali topish mumkin.",
        calmHeader: "OSOYISHTA INTERFEYS",
        grayscale: "Oq-qora rejim",
        calmFooterFormat: "Butun interfeys oq-qora boʻladi. GIF va videolarni avtomatik ijro etish “%1$@” boʻlimida, “%2$@” esa “%3$@” boʻlimida sozlanadi.",
        appIconPhone: "Telefon",
        appIconFeather: "Pat",
        appIconWeight: "Tosh"
    ),
    "id": JustgramTranslation(
        off: "Mati",
        inactiveHeader: "SEMBUNYIKAN OBROLAN TIDAK AKTIF",
        inactiveFooter: "Obrolan tanpa pesan baru lebih lama dari ini disembunyikan dari daftar. Obrolan yang disematkan selalu tetap ada. Gunakan Pencarian untuk menemukan obrolan tersembunyi; pesan baru akan mengembalikannya.",
        hideUnread: "Sembunyikan Juga yang Belum Dibaca",
        hideUnreadFooter: "Jika mati, obrolan tidak aktif yang tidak dibisukan dan memiliki pesan belum dibaca tetap ada di daftar sampai Anda membacanya.",
        hideChannels: "Sembunyikan Kanal",
        hideChannelsFooter: "Kanal dihapus dari daftar obrolan dan lencana. Anda tetap dapat menemukannya di Pencarian.",
        calmHeader: "ANTARMUKA TENANG",
        grayscale: "Skala Abu-abu",
        calmFooterFormat: "Seluruh antarmuka menjadi skala abu-abu. Putar otomatis GIF dan video diatur di “%1$@”, dan “%2$@” di “%3$@”.",
        appIconPhone: "Telepon",
        appIconFeather: "Bulu",
        appIconWeight: "Pemberat"
    ),
    "ms": JustgramTranslation(
        off: "Mati",
        inactiveHeader: "SEMBUNYIKAN SEMBANG TIDAK AKTIF",
        inactiveFooter: "Sembang tanpa mesej baharu lebih lama daripada tempoh ini disembunyikan daripada senarai. Sembang yang disematkan sentiasa kekal. Gunakan Carian untuk mencari sembang tersembunyi; mesej baharu akan membawanya kembali.",
        hideUnread: "Sembunyikan Juga yang Belum Dibaca",
        hideUnreadFooter: "Apabila dimatikan, sembang tidak aktif yang tidak dibisukan dengan mesej belum dibaca kekal dalam senarai sehingga anda membacanya.",
        hideChannels: "Sembunyikan Saluran",
        hideChannelsFooter: "Saluran dialih keluar daripada senarai sembang dan lencana. Anda masih boleh mencarinya dalam Carian.",
        calmHeader: "ANTARA MUKA TENANG",
        grayscale: "Skala Kelabu",
        calmFooterFormat: "Seluruh antara muka menjadi skala kelabu. Main automatik GIF dan video ditetapkan dalam “%1$@”, dan “%2$@” dalam “%3$@”.",
        appIconPhone: "Telefon",
        appIconFeather: "Bulu",
        appIconWeight: "Pemberat"
    ),
    "ar": JustgramTranslation(
        off: "إيقاف",
        inactiveHeader: "إخفاء المحادثات غير النشطة",
        inactiveFooter: "تُخفى من القائمة المحادثات التي لم تصلها رسائل جديدة لمدة أطول من هذه. تبقى المحادثات المثبتة دائمًا. استخدم البحث للعثور على محادثة مخفية، وستعيدها أي رسالة جديدة إلى القائمة.",
        hideUnread: "إخفاء غير المقروءة أيضًا",
        hideUnreadFooter: "عند الإيقاف، تبقى المحادثة غير النشطة وغير المكتومة التي فيها رسائل غير مقروءة في القائمة حتى تقرأها.",
        hideChannels: "إخفاء القنوات",
        hideChannelsFooter: "تُزال القنوات من قائمة المحادثات ومن العدّاد. يمكنك العثور عليها عبر البحث.",
        calmHeader: "واجهة هادئة",
        grayscale: "تدرّج الرمادي",
        calmFooterFormat: "تصبح الواجهة كلها بتدرّج الرمادي. يُضبط التشغيل التلقائي لصور GIF والفيديو في «%1$@»، و«%2$@» في «%3$@».",
        appIconPhone: "هاتف",
        appIconFeather: "ريشة",
        appIconWeight: "ثقل"
    ),
    "fa": JustgramTranslation(
        off: "خاموش",
        inactiveHeader: "پنهان کردن گفتگوهای غیرفعال",
        inactiveFooter: "گفتگوهایی که بیش از این مدت پیام جدیدی نداشته‌اند از فهرست پنهان می‌شوند. گفتگوهای سنجاق‌شده همیشه می‌مانند. برای پیدا کردن گفتگوی پنهان از جستجو استفاده کنید؛ یک پیام جدید آن را به فهرست برمی‌گرداند.",
        hideUnread: "پنهان کردن خوانده‌نشده‌ها هم",
        hideUnreadFooter: "وقتی خاموش است، گفتگوی غیرفعالی که بی‌صدا نشده و پیام خوانده‌نشده دارد تا وقتی آن را بخوانید در فهرست می‌ماند.",
        hideChannels: "پنهان کردن کانال‌ها",
        hideChannelsFooter: "کانال‌ها از فهرست گفتگوها و شمارنده حذف می‌شوند. همچنان می‌توانید آن‌ها را با جستجو پیدا کنید.",
        calmHeader: "رابط آرام",
        grayscale: "سیاه‌وسفید",
        calmFooterFormat: "کل رابط کاربری سیاه‌وسفید می‌شود. پخش خودکار GIF و ویدیو در «%1$@» تنظیم می‌شود و «%2$@» در «%3$@».",
        appIconPhone: "تلفن",
        appIconFeather: "پر",
        appIconWeight: "وزنه"
    ),
    "he": JustgramTranslation(
        off: "כבוי",
        inactiveHeader: "הסתרת צ׳אטים לא פעילים",
        inactiveFooter: "צ׳אטים ללא הודעות חדשות במשך זמן ארוך מזה מוסתרים מהרשימה. צ׳אטים מוצמדים נשארים תמיד. אפשר למצוא צ׳אט מוסתר דרך החיפוש, והודעה חדשה מחזירה אותו לרשימה.",
        hideUnread: "להסתיר גם צ׳אטים שלא נקראו",
        hideUnreadFooter: "כשהאפשרות כבויה, צ׳אט לא פעיל שאינו מושתק ויש בו הודעות שלא נקראו נשאר ברשימה עד שתקראו אותו.",
        hideChannels: "להסתיר ערוצים",
        hideChannelsFooter: "ערוצים מוסרים מרשימת הצ׳אטים ומהמונה. עדיין אפשר למצוא אותם בחיפוש.",
        calmHeader: "ממשק רגוע",
        grayscale: "גווני אפור",
        calmFooterFormat: "כל הממשק הופך לגווני אפור. ההפעלה האוטומטית של GIF וסרטונים מוגדרת בהגדרה \"%1$@\", ו\"%2$@\" בהגדרה \"%3$@\".",
        appIconPhone: "טלפון",
        appIconFeather: "נוצה",
        appIconWeight: "משקולת"
    ),
    "ko": JustgramTranslation(
        off: "끔",
        inactiveHeader: "비활성 채팅 숨기기",
        inactiveFooter: "이 기간보다 오래 새 메시지가 없는 채팅은 목록에서 숨겨집니다. 고정된 채팅은 항상 표시됩니다. 숨겨진 채팅은 검색으로 찾을 수 있으며, 새 메시지가 오면 다시 목록에 나타납니다.",
        hideUnread: "읽지 않은 채팅도 숨기기",
        hideUnreadFooter: "끄면, 음소거하지 않았고 읽지 않은 메시지가 있는 비활성 채팅은 읽을 때까지 목록에 남아 있습니다.",
        hideChannels: "채널 숨기기",
        hideChannelsFooter: "채널이 채팅 목록과 배지에서 제거됩니다. 검색으로는 계속 찾을 수 있습니다.",
        calmHeader: "차분한 인터페이스",
        grayscale: "흑백",
        calmFooterFormat: "전체 인터페이스가 흑백으로 바뀝니다. GIF와 동영상 자동 재생은 '%1$@'에서, '%2$@'은(는) '%3$@'에서 설정합니다.",
        appIconPhone: "전화기",
        appIconFeather: "깃털",
        appIconWeight: "저울추"
    )
]

/// Titles of Justgram's app icons in the Appearance icon picker.
func justgramAppIconTitle(_ name: String, strings: PresentationStrings) -> String? {
    let strings = JustgramStrings(strings: strings)
    switch name {
    case "JustgramPhone":
        return strings.appIconPhone
    case "JustgramFeather":
        return strings.appIconFeather
    case "JustgramWeight":
        return strings.appIconWeight
    default:
        return nil
    }
}
