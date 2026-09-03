document.addEventListener("DOMContentLoaded", () => {
    console.log("Scriptul s-a încărcat cu succes!");

    // ================= CARUSEL IMAGINI =================
    const slide = document.querySelector(".carousel-slide");
    const btnPrev = document.getElementById("btn-prev");
    const btnNext = document.getElementById("btn-next");
    let index = 0;

    if (slide && btnPrev && btnNext) {
        btnNext.addEventListener("click", () => {
            if (index < 1) {
                index++;
                slide.style.transform = `translateX(-${index * 100}%)`;
            } else {
                index = 0;
                slide.style.transform = `translateX(0%)`;
            }
        });

        btnPrev.addEventListener("click", () => {
            if (index > 0) {
                index--;
                slide.style.transform = `translateX(-${index * 100}%)`;
            } else {
                index = 1;
                slide.style.transform = `translateX(-100%)`;
            }
        });
        console.log("Caruselul a fost inițializat cu succes.");
    } else {
        console.warn("Atenție: Elementele caruselului nu au fost găsite în HTML.");
    }


    // ================= LOGICA PENTRU MODAL (POP-UP) =================
    const modal = document.getElementById("booking-modal");
    const btnOpenMain = document.getElementById("btn-test"); // Butonul mare de test din pagină
    const btnOpenNav = document.getElementById("nav-rezerva"); // Butonul din meniu
    const btnClose = document.getElementById("close-modal");
    const contactModal= document.getElementById("contact-modal");
    const btnOpenContact= document.getElementById("nav-contact");//butonul de contact
    const btnCloseContact= document.getElementById("close-contact-modal");

    // Funcție de deschidere a ferestrei
    function deschideModal(e) {
        e.preventDefault(); 
        if (modal) {
            modal.classList.add("active");
        }
    }
    //functia de deschidere Contact
    function deschideContact(e){
        e.preventDefault();
        if(contactModal) contactModal.classList.add("active");
    }

    // Funcție de închidere a ferestrei
    function inchideModal() {
        if (modal) {
            modal.classList.remove("active");
        }
    }
    //functia de inchidere Contact
    function inchideContact(){
        if(contactModal) contactModal.classList.remove("active");
    }

    // Punem evenimentele doar dacă butoanele chiar există în HTML
    if (btnOpenMain) {
        btnOpenMain.addEventListener("click", deschideModal);
    }
    if (btnOpenNav) {
        btnOpenNav.addEventListener("click", deschideModal);
    }
    if (btnClose) {
        btnClose.addEventListener("click", inchideModal);
    }
    
    if (modal) {
        modal.addEventListener("click", (e) => {
            if (e.target === modal) {
                inchideModal();
            }
        });
    }
    //evenimente pentru contact
    if(btnOpenContact){
        btnOpenContact.addEventListener("click",deschideContact);
    }
    if(btnCloseContact){
        btnCloseContact.addEventListener("click",inchideContact);
    }
    if(contactModal){
        contactModal.addEventListener("click",(e)=>{
            if(e.target=== contactModal){
                inchideContact();
            }
        });
    }


   
// ================= CALCULATORUL DE PREȚ CU EXTRA =================
const checkInInput = document.getElementById("check-in");
    const checkOutInput = document.getElementById("check-out");
    const totalPriceSpan = document.getElementById("total-price");
    const extraCheckboxes = document.querySelectorAll(".extra-option");
    const pretBazaCabana = 600;

    const step1 = document.getElementById("booking-step-1");
    const step2 = document.getElementById("booking-step-2");
    const btnNextStep = document.getElementById("btn-next-step");
    const btnBackStep = document.getElementById("btn-back-step");
    const modalTitle = document.getElementById("modal-step-title");
    const summaryText = document.getElementById("summary-text");

    // Declarăm variabila let pentru a putea fi populată ulterior din API
    let dateOcupate = [];

    // 1. Funcția care aduce datele din API
async function incarcareDateOcupate() {
    try {
        const response = await fetch('https://cabanabookingapi.onrender.com/api/Rezervari/date-ocupate');
        if (response.ok) {
            dateOcupate = await response.json();
            console.log("Date ocupate din baza de date Oracle:", dateOcupate);
            
            // Re-inițializăm calendarele după ce avem datele reale
            initCalendare();
        }
    } catch (error) {
        console.error("Eroare la conectarea cu backend-ul C#:", error);
    }
}

// Funcție ajutătoare pentru formatarea corectă a datei fără decalaj de fus orar (UTC)

    function getLocalDateString(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }
//Mutăm tot codul de inițializare Flatpickr într-o funcție
function initCalendare() {

    if (checkInInput && checkOutInput) {

        // 1. Calendar Check-Out
        const pickerCheckOut = flatpickr(checkOutInput, {
            minDate: "today",
            dateFormat: "Y-m-d",
            // NU mai folosim disable: [...] pentru a nu bloca pointer-events
            onDayCreate: function(dObj, dStr, fp, dayElement) {
                const formattedDate = getLocalDateString(dayElement.dateObj);
                if (dateOcupate.includes(formattedDate)) {
                    dayElement.classList.add("zi-rezervata");
                }
            },
            onChange: function(selectedDates, dateStr, instance) {
                if (!selectedDates.length) return;
                
                const checkInDate = new Date(checkInInput.value);
                checkInDate.setHours(0,0,0,0);
                
                const selectedOut = new Date(selectedDates[0]);
                selectedOut.setHours(0,0,0,0);

                // Găsim prima zi ocupată de după Check-In
                const urmatoareaOcupata = dateOcupate
                    .map(d => new Date(d))
                    .filter(d => d > checkInDate)
                    .sort((a, b) => a - b)[0];

                if (urmatoareaOcupata) {
                    urmatoareaOcupata.setHours(0,0,0,0);
                    // Dacă încearcă să selecteze DUPĂ prima zi ocupată, anulăm selecția
                    if (selectedOut > urmatoareaOcupata) {
                        alert("Nu poți include zile deja rezervate în sejur!");
                        instance.clear();
                        if (totalPriceSpan) totalPriceSpan.textContent = "0";
                        return;
                    }
                }

                calculeazaPret();
            }
        });

        // 2. Calendar Check-In
        flatpickr(checkInInput, {
            minDate: "today",
            dateFormat: "Y-m-d",
            disable: [
                function(date) {
                    const dateStr = getLocalDateString(date);
                    return dateOcupate.includes(dateStr); // La Check-In rămâne blocat normal
                }
            ],
            onDayCreate: function(dObj, dStr, fp, dayElement) {
                const formattedDate = getLocalDateString(dayElement.dateObj);
                if (dateOcupate.includes(formattedDate)) {
                    dayElement.classList.add("zi-rezervata");
                }
            },
            onChange: function(selectedDates) {
                if (selectedDates.length > 0) {
                    const nextDay = new Date(selectedDates[0]);
                    nextDay.setDate(nextDay.getDate() + 1);

                    pickerCheckOut.set("minDate", getLocalDateString(nextDay));
                    checkOutInput.value = "";
                    if (totalPriceSpan) totalPriceSpan.textContent = "0";
                }
            }
        });
    }
}

    // Limitează data de check-in la ziua curentă
    const astazi = new Date().toISOString().split('T')[0];
    if (checkInInput) checkInInput.min = astazi;

    function calculeazaPret() {
        if (!checkInInput || !checkOutInput || !checkInInput.value || !checkOutInput.value) {
            if (totalPriceSpan) totalPriceSpan.textContent = "0";
            return 0;
        }

        const dataIntrare = new Date(checkInInput.value);
        const dataIesire = new Date(checkOutInput.value);

        if (dataIesire <= dataIntrare) {
            if (totalPriceSpan) totalPriceSpan.textContent = "0";
            return 0;
        }

        const diferentaTimp = dataIesire.getTime() - dataIntrare.getTime();
        const nopti = Math.ceil(diferentaTimp / (1000 * 60 * 60 * 24));
        let pretTotal = pretBazaCabana * nopti;

        extraCheckboxes.forEach(checkbox => {
            if (checkbox.checked) {
                pretTotal += parseFloat(checkbox.value);
            }
        });

        if (totalPriceSpan) totalPriceSpan.textContent = pretTotal;
        return { nopti, pretTotal };
    }

    if (checkInInput && checkOutInput) {
        checkInInput.addEventListener("change", () => {
            checkOutInput.min = checkInInput.value;
            calculeazaPret();
        });
        checkOutInput.addEventListener("change", calculeazaPret);
    }

    extraCheckboxes.forEach(checkbox => {
        checkbox.addEventListener("change", calculeazaPret);
    });

    // Trecerea de la Pasul 1 la Pasul 2
    if (btnNextStep) {
        btnNextStep.addEventListener("click", () => {
            if (!checkInInput.value || !checkOutInput.value) {
                const currentLang = document.getElementById('language-select')?.value || localStorage.getItem('selectedLanguage') || 'ro';
                alert(translations[currentLang]?.alert_select_dates || "Te rugăm să selectezi datele de Check-In și Check-Out!");
                return;
            }

            const res = calculeazaPret();
            if (!res || res.nopti <= 0) {
                const currentLang = document.getElementById('language-select')?.value || localStorage.getItem('selectedLanguage') || 'ro';
                alert(translations[currentLang]?.alert_date_error || "Eroare: Data de Check-Out trebuie să fie după Data de Check-In!");
                return;
            }

            // Trecem vizual la pasul 2
            step1.style.display = "none";
            step2.style.display = "block";
            if (modalTitle) {
                const currentLang = document.getElementById('language-select')?.value || localStorage.getItem('selectedLanguage') || 'ro';
                modalTitle.setAttribute('data-i18n', 'step2_title');
                modalTitle.textContent = translations[currentLang]?.step2_title || "Pasul 2: Date Personale & Facturare";
            }
            
            if (summaryText) {
                summaryText.textContent = `${res.nopti} nopți (${checkInInput.value} ➡️ ${checkOutInput.value}) | Total: ${res.pretTotal} RON`;
            }
        });
    }

    // Întoarcerea de la Pasul 2 la Pasul 1
    if (btnBackStep) {
        btnBackStep.addEventListener("click", () => {
            step2.style.display = "none";
            step1.style.display = "block";
            if (modalTitle) {
                const currentLang = document.getElementById('language-select')?.value || localStorage.getItem('selectedLanguage') || 'ro';
                modalTitle.setAttribute('data-i18n', 'modal_title');
                modalTitle.textContent = translations[currentLang]?.modal_title || "Pasul 1: Calculează sejurul la Our Nest";
            }
        });
    }

    // Trimiterea finală a rezervării (Pasul 2)
    const bookingForm = document.getElementById("booking-form");
    if (bookingForm) {
        bookingForm.addEventListener("submit",async (e) => {
            e.preventDefault();

            const nume = document.getElementById("client-nume").value.trim();
            const prenume = document.getElementById("client-prenume").value.trim();
            const telefon = document.getElementById("client-telefon").value.trim();
            const email = document.getElementById("client-email").value.trim();
            const cnp = document.getElementById("client-cnp").value.trim();

            if (!nume || !prenume || !telefon || !email || !cnp) {
                const currentLang = document.getElementById('language-select')?.value || localStorage.getItem('selectedLanguage') || 'ro';
                alert(translations[currentLang]?.alert_fill_required || "Te rugăm să completezi toate câmpurile cu datele personale!");
                return;
            }

            // Colectăm opțiunile extra
            let extraAlese = [];
            extraCheckboxes.forEach(cb => {
                if (cb.checked) extraAlese.push(cb.getAttribute("data-name"));
            });

            // Obiectul JSON complet care va fi trimis spre Backend C# / API
            const comandaRezervare = {
                client: { nume, prenume, telefon, email, cnp },
                rezervare: {
                    checkIn: checkInInput.value,
                    checkOut: checkOutInput.value,
                    pretTotal: totalPriceSpan.textContent,
                    optiuniExtra: extraAlese
                }
            };
            // Trimiterea propriu-zisă către Web API (Backend C#)
            try {
                const response = await fetch('https://cabanabookingapi.onrender.com/api/Rezervari', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(comandaRezervare)
                });

                const result = await response.json();

                if (response.ok) {
                    alert(`Rezervare salvată cu succes!\n\nClient: ${nume} ${prenume}\nTotal: ${totalPriceSpan.textContent} RON.\n\nRezervarea a fost înregistrată în baza de date!`);

                    // Resetare modal
                    bookingForm.reset();
                    step2.style.display = "none";
                    step1.style.display = "block";
                    if (modalTitle) modalTitle.textContent = "Pasul 1: Calculează sejurul la Our Nest";
                    
                    const bookingModal = document.getElementById("booking-modal");
                    if (bookingModal) bookingModal.classList.remove("active");
                } else {
                    alert("Eroare la salvarea rezervării: " + result.message);
                }
            } catch (error) {
                console.error("Eroare la conectarea cu API-ul:", error);
                alert("Nu s-a putut conecta la serverul backend. Asigură-te că aplicația din Visual Studio rulează!");
            }
    

            console.log("Date pregătite pentru Oracle SQL / Backend:", comandaRezervare);

            alert(`Rezervare trimisă cu succes!\n\nClient: ${nume} ${prenume}\nTelefon: ${telefon}\nTotal: ${totalPriceSpan.textContent} RON.\n\nDatele au fost salvate și trimise către administrare!`);

            // Resetare modal
            bookingForm.reset();
            step2.style.display = "none";
            step1.style.display = "block";
            if (modalTitle) modalTitle.textContent = "Pasul 1: Calculează sejurul la Our Nest";
            
            const bookingModal = document.getElementById("booking-modal");
            if (bookingModal) bookingModal.classList.remove("active");
    });
};

 

    const infoModal= document.getElementById('info-modal');
    const btnDespreNavbar=document.getElementById('btn-despre');
    const btnCloseInfo=document.getElementById('close-info');

    const infoslide=document.querySelector('#info-modal .info-carousel-slide');
    const infoSlideItems=document.querySelectorAll('#info-modal .info-slide-item');
    const infoBtnPrev=document.getElementById('info-btn-prev');
    const infoBtnNext=document.getElementById('info-btn-next');

    let infoIndex=0;

    //Deschide modalul cand sa da click pe "Despre noi" in navbar
    if(btnDespreNavbar){
        btnDespreNavbar.addEventListener('click',(e)=>{
            e.preventDefault();//previne saltul paginii
           if(infoModal){
            infoModal.style.display='block';
            infoModal.classList.add('active');
            document.body.style.overflow='hidden';// opreste scrolul paginii
           }
        });
    }
    //inchide modal la click pe x
    if(btnCloseInfo){
        btnCloseInfo.addEventListener('click',()=>{
            if(infoModal){
                infoModal.style.display='none';
                infoModal.classList.remove('active');
                document.body.style.overflow='auto';//opreste blocarea scrollului

                 infoIndex=0;
            if(infoslide){
                infoslide.style.transform='translateX(0%)';
                }
       
            }
        });
    }
       
 

    //controlul miscarii imaginii in carouselul secundar

    function updateInfoCarousel(){
        if(infoslide){
            infoslide.style.transform=`translateX(-${infoIndex * 100}%)`;
        }
    }
if(infoBtnNext){
    infoBtnNext.addEventListener('click',() =>{
        if(infoIndex<infoSlideItems.length-1){
            infoIndex++;
        }else{
            infoIndex=0;
        }
        updateInfoCarousel();
    });
}
if(infoBtnPrev){
    infoBtnPrev.addEventListener('click',()=>{
        if(infoIndex > 0){
            infoIndex--;
        }else{
            infoIndex=infoSlideItems.length-1;
        }
        updateInfoCarousel();
     });
    }
// ================= SERVICII EXTRA - MODAL & CARUSEL =================
    const btnExtra = document.getElementById('btn-extra');
    const extraModal = document.getElementById('extra-modal');
    const closeExtraModal = document.getElementById('close-extra-modal');

    const extraSlide = document.getElementById('extra-carousel-slide');
    const extraPrevBtn = document.getElementById('extra-btn-prev');
    const extraNextBtn = document.getElementById('extra-btn-next');

    let extraIndex = 0;

    // Deschidere Modal "Extra"
    if (btnExtra && extraModal) {
        btnExtra.addEventListener('click', (e) => {
            e.preventDefault();
            extraModal.style.display = 'block';
            extraModal.classList.add('active');
            document.body.style.overflow = 'hidden'; // Oprește scroll-ul pe fundal
        });
    }

    // Închidere Modal "Extra" la click pe butonul X
    if (closeExtraModal && extraModal) {
        closeExtraModal.addEventListener('click', () => {
            extraModal.style.display = 'none';
            extraModal.classList.remove('active');
            document.body.style.overflow = 'auto'; // Reia scroll-ul
            
            // Resetează caruselul la prima imagine
            extraIndex = 0;
            if (extraSlide) {
                extraSlide.style.transform = 'translateX(0%)';
            }
        });
    }

    // Închidere Modal "Extra" la click pe fundalul întunecat
    if (extraModal) {
        extraModal.addEventListener('click', (e) => {
            if (e.target === extraModal) {
                extraModal.style.display = 'none';
                extraModal.classList.remove('active');
                document.body.style.overflow = 'auto';
                
                extraIndex = 0;
                if (extraSlide) {
                    extraSlide.style.transform = 'translateX(0%)';
                }
            }
        });
    }

    // Navigare Carusel Extra
    function updateExtraCarousel() {
        if (extraSlide) {
            extraSlide.style.transform = `translateX(-${extraIndex * 100}%)`;
        }
    }

    if (extraNextBtn) {
        extraNextBtn.addEventListener('click', () => {
            const extraSlidesCount = extraModal ? extraModal.querySelectorAll('.info-slide-item').length : 3;
            if (extraIndex < extraSlidesCount - 1) {
                extraIndex++;
            } else {
                extraIndex = 0;
            }
            updateExtraCarousel();
        });
    }

    if (extraPrevBtn) {
        extraPrevBtn.addEventListener('click', () => {
            const extraSlidesCount = extraModal ? extraModal.querySelectorAll('.info-slide-item').length : 3;
            if (extraIndex > 0) {
                extraIndex--;
            } else {
                extraIndex = extraSlidesCount - 1;
            }
            updateExtraCarousel();
        });
    }
// ================= SISTEM TRADUCERI (i18n) =================
    const translations = {
    ro: {
        // Meniu & Hero
        nav_despre: "Despre Noi",
        nav_extra: "Extra",
        nav_rezerva: "Rezerva",
        nav_contact: "Contact",
        hero_title: "Bine ati venit la Our Nest",
        hero_subtitle: "O oaza de liniste in mijlocul naturii.",
        btn_rezerva_acum: "Rezerva Acum",

        // Modal Rezervare Pasul 1
        modal_title: "Pasul 1: Calculează sejurul la Our Nest",
        label_tip_rezervare: "Tip rezervare:",
        label_checkin: "Data Check-in:",
        label_checkout: "Data Check-out:",
        label_optiuni_extra: "Opțiuni & Pachete de Bun Venit (Opțional):",
        extra_sampanie: "🍾 Șampanie rece la sosire (+150 RON)",
        extra_vin: "🍷 Selecție Vin Premium (+100 RON)",
        extra_decor: "🌹 Decor floral & petale trandafir (+200 RON)",
        label_pret_total: "Preț total:",
        btn_next: "Avansează la Date Personale ➡️",

        // Modal Rezervare Pasul 2
        step2_desc: "Aproape gata! Introdu datele tale pentru confirmarea rezervării și emiterea facturii:",
        label_nume: "Nume:*",
        label_prenume: "Prenume:*",
        label_telefon: "Telefon:*",
        label_cnp: "CNP / Serie & Nr. CI (necesar pentru cazare & factură):*",

        // Modal Contact
        contact_title: "Contact & Social Media",
        contact_subtitle: "Ai intrebari sau vrei sa ne urmaresti? Ne gasesti aici:",
        contact_heading_info: "Date de Contact",
        contact_phone: "Telefon",
        contact_address: "Adresa Cabana",
        contact_heading_social: "Urmareste-ne",
        contact_text_social: "Apasa pe link-urile urmatoare pentru a ne vizita",

        // Modal Despre Noi
        about_jacuzzi_title: "Jacuzzi pentru doua persoane",
        about_jacuzzi_desc: "Relaxare totală sub cerul liber, înconjurat de pădure. Inclus în prețul nopții de cazare, pregătit și încălzit exact la temperatura ideală pentru sosirea ta.",
        about_gratar_title: "Terasa si Gratar",
        about_gratar_desc: "Tot ce ai nevoie pentru o seară perfectă: grătar profesional, lemne și cărbuni din partea casei, plus un foișor acoperit unde poți lua masa în siguranță.",
        about_interior_title: "Confort Interior Complet",
        about_interior_desc: "Bucătărie complet utilată, espressor cu cafea premium inclusă, Wi-Fi de mare viteză pentru momentele în care vrei să rămâi conectat și un living călduros.",

        // Modal Servicii Extra
        extra_slide1_title: "Șampanie Fină la Sosire",
        extra_slide1_desc: "Sărbătorește sosirea cu o sticla de șampanie rece, pregătită cu gheață direct în cameră, gata pentru momentul în care pui piciorul în cabană.",
        extra_slide2_title: "Selecție de Vinuri de Colecție",
        extra_slide2_desc: "Alege o sticlă de vin roșu sau alb din crame selecționate, perfectă pentru o seară liniștită lângă șemineu sau pe terasă.",
        extra_slide3_title: "Aranjamente Florale pentru Îndrăgostiți",
        extra_slide3_desc: "Surprinde-ți partenerul/partenera! Pregătim un decor romantic cu buchete de flori proaspete și petale de trandafir aranjate cu grijă.",

        // Subsol (Footer)
        footer_contact_rapid: "Contact Rapid",
        footer_copyright: "© 2026 Our Nest. Toate drepturile rezervate.",
        legal_privacy: "Politica de Confidențialitate",
        legal_cookies: "Politica de Cookie-uri",
        legal_cookie_settings: "Setări cookie",
        legal_terms: "Termeni și Condiții",
        //ce am uitat sa traduc
        text_entreaga_cabana: "Întreaga Cabană",
        text_per_night: "noapte",
        label_email: "Email:*",
        label_sumar: "Sumar:",
        btn_back: "⬅️ Înapoi",
        btn_submit: "Finalizează & Trimitere Rezervare",
        footer_program: "Program",
        footer_location: "Locație liniștită",
        step2_title: "Pasul 2: Date Personale & Facturare",
        alert_select_dates: "Te rugăm să selectezi datele de Check-In și Check-Out!",
        alert_date_error: "Eroare: Data de Check-Out trebuie să fie după Data de Check-In!",
        alert_fill_required: "Te rugăm să completezi toate câmpurile cu datele personale!"
    },
    en: {
        // Meniu & Hero
        nav_despre: "About Us",
        nav_extra: "Extras",
        nav_rezerva: "Book Now",
        nav_contact: "Contact",
        hero_title: "Welcome to Our Nest",
        hero_subtitle: "An oasis of peace in the middle of nature.",
        btn_rezerva_acum: "Book Now",

        // Modal Rezervare Pasul 1
        modal_title: "Step 1: Calculate your stay at Our Nest",
        label_tip_rezervare: "Reservation type:",
        label_checkin: "Check-in Date:",
        label_checkout: "Check-out Date:",
        label_optiuni_extra: "Extra Options & Welcome Packages (Optional):",
        extra_sampanie: "🍾 Cold champagne upon arrival (+150 RON)",
        extra_vin: "🍷 Premium Wine Selection (+100 RON)",
        extra_decor: "🌹 Romantic floral decor & rose petals (+200 RON)",
        label_pret_total: "Total price:",
        btn_next: "Proceed to Personal Details ➡️",

        // Modal Rezervare Pasul 2
        step2_desc: "Almost done! Enter your details for booking confirmation and invoicing:",
        label_nume: "Last Name:*",
        label_prenume: "First Name:*",
        label_telefon: "Phone:*",
        label_cnp: "National ID / Passport Number:*",

        // Modal Contact
        contact_title: "Contact & Social Media",
        contact_subtitle: "Have questions or want to follow us? Find us here:",
        contact_heading_info: "Contact Details",
        contact_phone: "Phone",
        contact_address: "Cabin Address",
        contact_heading_social: "Follow Us",
        contact_text_social: "Click on the following links to visit our pages",

        // Modal Despre Noi
        about_jacuzzi_title: "Jacuzzi for two people",
        about_jacuzzi_desc: "Total relaxation under the open sky, surrounded by forest. Included in the night's rate, heated to the ideal temperature for your arrival.",
        about_gratar_title: "Terrace and BBQ",
        about_gratar_desc: "Everything you need for a perfect evening: professional grill, firewood and charcoal on the house, plus a covered gazebo.",
        about_interior_title: "Full Interior Comfort",
        about_interior_desc: "Fully equipped kitchen, espresso machine with premium coffee included, high-speed Wi-Fi, and a cozy living room.",

        // Modal Servicii Extra
        extra_slide1_title: "Fine Champagne on Arrival",
        extra_slide1_desc: "Celebrate your arrival with a bottle of chilled champagne with ice directly in your room.",
        extra_slide2_title: "Collection Wine Selection",
        extra_slide2_desc: "Choose a bottle of red or white wine from selected wineries, perfect for a quiet evening by the fireplace.",
        extra_slide3_title: "Floral Arrangements for Lovers",
        extra_slide3_desc: "Surprise your partner! We prepare a romantic setting with fresh flower bouquets and carefully arranged rose petals.",

        // Subsol (Footer)
        footer_contact_rapid: "Quick Contact",
        footer_copyright: "© 2026 Our Nest. All rights reserved.",
        legal_privacy: "Privacy Policy",
        legal_cookies: "Cookie Policy",
        legal_cookie_settings: "Cookie Settings",
        legal_terms: "Terms and Conditions",
        //ce am uitat sa traduc
        text_entreaga_cabana: "Entire Cabin",
        text_per_night: "night",
        label_email: "Email:*",
        label_sumar: "Summary:",
        btn_back: "⬅️ Back",
        btn_submit: "Complete & Send Booking",
        footer_program: "Schedule",
        footer_location: "Quiet location",
        step2_title: "Step 2: Personal Details & Invoicing",
        lert_select_dates: "Please select Check-In and Check-Out dates!",
        alert_date_error: "Error: Check-Out date must be after Check-In date!",
        alert_fill_required: "Please fill in all required personal details!"
    },
    hu: {
        // Meniu & Hero
        nav_despre: "Rólunk",
        nav_extra: "Extrák",
        nav_rezerva: "Foglalás",
        nav_contact: "Kapcsolat",
        hero_title: "Üdvözöljük a Our Nest-ben",
        hero_subtitle: "A béke szigete a természet közepén.",
        btn_rezerva_acum: "Foglaljon Most",

        // Modal Rezervare Pasul 1
        modal_title: "1. lépés: Számítsa ki az itt tartózkodást",
        label_tip_rezervare: "Foglalás típusa:",
        label_checkin: "Bejelentkezés dátuma:",
        label_checkout: "Kijelentkezés dátuma:",
        label_optiuni_extra: "Extra opciók & Üdvözlő csomagok (Opcionális):",
        extra_sampanie: "🍾 Hideg pezsgő érkezéskor (+150 RON)",
        extra_vin: "🍷 Prémium borválogatás (+100 RON)",
        extra_decor: "🌹 Romantikus virágdekoráció & rózsaszirmok (+200 RON)",
        label_pret_total: "Teljes ár:",
        btn_next: "Tovább a személyes adatokhoz ➡️",

        // Modal Rezervare Pasul 2
        step2_desc: "Majdnem kész! Adja meg adatait a foglalás megerősítéséhez és a számlázáshoz:",
        label_nume: "Vezetéknév:*",
        label_prenume: "Keresztnév:*",
        label_telefon: "Telefonszám:*",
        label_cnp: "Személyi igazolvány / Útlevélszám:*",

        // Modal Contact
        contact_title: "Kapcsolat & Közösségi Média",
        contact_subtitle: "Kérdése van, vagy követne minket? Itt megtalál:",
        contact_heading_info: "Elérhetőségek",
        contact_phone: "Telefon",
        contact_address: "Kunyhó címe",
        contact_heading_social: "Kövessen minket",
        contact_text_social: "Kattintson az alábbi linkekre az oldalaink meglátogatásához",

        // Modal Despre Noi
        about_jacuzzi_title: "Jakuzzi két személyre",
        about_jacuzzi_desc: "Teljes kikapcsolódás a szabad ég alatt, erdővel körülvéve. Az ár tartalmazza, tökéletes hőmérsékletre melegítve az érkezésére.",
        about_gratar_title: "Terasz és Grillező",
        about_gratar_desc: "Minden, ami egy tökéletes estéhez kell: professzionális grill, tűzifa és faszén a ház ajándékaként, plusz fedett filagória.",
        about_interior_title: "Teljes Belső Kényelem",
        about_interior_desc: "Teljesen felszerelt konyha, eszpresszógép prémium kávéval, nagy sebességű Wi-Fi és meleg nappali.",

        // Modal Servicii Extra
        extra_slide1_title: "Finom Pezsgő Érkezéskor",
        extra_slide1_desc: "Ünnepelje meg megérkezését egy üveg hűtött pezsgővel, jéggel előkészítve közvetlenül a szobában.",
        extra_slide2_title: "Válogatott Kollekciós Borok",
        extra_slide2_desc: "Válasszon egy üveg vörös- vagy fehérbort válogatott pincészetekből, tökéletes egy csendes estéhez a kandalló mellett.",
        extra_slide3_title: "Virágkompozíciók Szerelmeseknek",
        extra_slide3_desc: "Lepje meg partnerét! Romantikus hangulatot készítünk elő friss virágcsokrokkal és gondosan elrendezett rózsaszirmokkal.",

        // Subsol (Footer)
        footer_contact_rapid: "Gyors Kapcsolat",
        footer_copyright: "© 2026 Our Nest. Minden jog fenntartva.",
        legal_privacy: "Adatvédelmi Irányelvek",
        legal_cookies: "Süti (Cookie) Szabályzat",
        legal_cookie_settings: "Süti beállítások",
        legal_terms: "Felhasználási Feltételek",
        //ce am uitat sa traduc
        text_entreaga_cabana: "Teljes Faház",
        text_per_night: "éjszaka",
        label_email: "E-mail:*",
        label_sumar: "Összegzés:",
        btn_back: "⬅️ Vissza",
        btn_submit: "Foglalás Véglegesítése",
        footer_program: "Nyitvatartás",
        footer_location: "Csendes elhelyezkedés",
        cstep2_title: "2. lépés: Személyes adatok és számlázás",
        alert_select_dates: "Kérjük, válassza ki a bejelentkezés és kijelentkezés dátumát!",
        alert_date_error: "Hiba: A kijelentkezés dátumának a bejelentkezés utáni napra kell esnie!",
        alert_fill_required: "Kérjük, töltse ki az összes kötelező személyes adatot!"
    },
    de: {
        // Meniu & Hero
        nav_despre: "Über uns",
        nav_extra: "Extras",
        nav_rezerva: "Buchen",
        nav_contact: "Kontakt",
        hero_title: "Willkommen im Our Nest",
        hero_subtitle: "Eine Oase der Ruhe mitten in der Natur.",
        btn_rezerva_acum: "Jetzt buchen",

        // Modal Rezervare Pasul 1
        modal_title: "Schritt 1: Berechnen Sie Ihren Aufenthalt im Our Nest",
        label_tip_rezervare: "Reservierungsart:",
        label_checkin: "Anreisedatum:",
        label_checkout: "Abreisedatum:",
        label_optiuni_extra: "Zusatzoptionen & Willkommenspakete (Optional):",
        extra_sampanie: "🍾 Kalter Champagner bei der Ankunft (+150 RON)",
        extra_vin: "🍷 Premium-Weinbereitschaft (+100 RON)",
        extra_decor: "🌹 Romantische Blumendekoration & Rosenblätter (+200 RON)",
        label_pret_total: "Gesamtpreis:",
        btn_next: "Weiter zu den persönlichen Daten ➡️",

        // Modal Rezervare Pasul 2
        step2_desc: "Fast fertig! Geben Sie Ihre Daten für die Buchungsbestätigung und Rechnungsstellung ein:",
        label_nume: "Nachname:*",
        label_prenume: "Vorname:*",
        label_telefon: "Telefon:*",
        label_cnp: "Personalausweisnummer / Passnummer:*",

        // Modal Contact
        contact_title: "Kontakt & Social Media",
        contact_subtitle: "Haben Sie Fragen oder möchten Sie uns folgen? Sie finden uns hier:",
        contact_heading_info: "Kontaktdaten",
        contact_phone: "Telefon",
        contact_address: "Adresse der Hütte",
        contact_heading_social: "Folgen Sie uns",
        contact_text_social: "Klicken Sie auf die folgenden Links, um unsere Seiten zu besuchen",

        // Modal Despre Noi
        about_jacuzzi_title: "Whirlpool für zwei Personen",
        about_jacuzzi_desc: "Entspannung pur unter freiem Himmel, umgeben von Wald. Im Übernachtungspreis enthalten und perfekt vorgeheizt.",
        about_gratar_title: "Terrasse und Grill",
        about_gratar_desc: "Alles für einen perfekten Abend: Profi-Grill, Holz und Holzkohle aufs Haus, plus überdachter Pavillon.",
        about_interior_title: "Kompletter Innenkomfort",
        about_interior_desc: "Voll ausgestattete Küche, Espressomaschine mit Premium-Kaffee inklusive, Highspeed-WLAN und gemütliches Wohnzimmer.",

        // Modal Servicii Extra
        extra_slide1_title: "Feiner Champagner bei der Ankunft",
        extra_slide1_desc: "Feiern Sie Ihre Ankunft mit einer Flasche gekühltem Champagner mit Eis direkt auf Ihrem Zimmer.",
        extra_slide2_title: "Ausgewählte Weinkollektion",
        extra_slide2_desc: "Wählen Sie eine Flasche Rot- oder Weißwein aus ausgewählten Weingütern für einen gemütlichen Abend am Kamin.",
        extra_slide3_title: "Blumenarrangements für Verliebte",
        extra_slide3_desc: "Überraschen Sie Ihren Partner! Wir bereiten eine romantische Atmosphäre mit frischen Blumensträußen und Rosenblättern vor.",

        // Subsol (Footer)
        footer_contact_rapid: "Schnellkontakt",
        footer_copyright: "© 2026 Our Nest. Alle Rechte vorbehalten.",
        legal_privacy: "Datenschutz-Bestimmungen",
        legal_cookies: "Cookie-Richtlinie",
        legal_cookie_settings: "Cookie-Einstellungen",
        legal_terms: "Allgemeine Geschäftsbedingungen",
        //ce am uitat sa traduc
        text_entreaga_cabana: "Ganze Hütte",
        text_per_night: "Nacht",
        label_email: "E-Mail:*",
        label_sumar: "Zusammenfassung:",
        btn_back: "⬅️ Zurück",
        btn_submit: "Buchung Abschließen & Senden",
        footer_program: "Zeiten",
        footer_location: "Ruhige Lage",
        step2_title: "Schritt 2: Persönliche Daten & Rechnungsstellung",
        alert_select_dates: "Bitte wählen Sie Anreise- und Abreisedatum aus!",
        alert_date_error: "Fehler: Das Abreisedatum muss nach dem Anreisedatum liegen!",
        alert_fill_required: "Bitte füllen Sie alle erforderlichen persönlichen Daten aus!"
    }
};

    function setLanguage(lang) {
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            if (translations[lang] && translations[lang][key]) {
                element.innerText = translations[lang][key];
            }
        });
        localStorage.setItem('selectedLanguage', lang);
    }

    const langSelect = document.getElementById('language-select');
    if (langSelect) {
        langSelect.addEventListener('change', (e) => {
            setLanguage(e.target.value);
        });

        // Setare limbă salvată la încărcare
        const savedLang = localStorage.getItem('selectedLanguage') || 'ro';
        langSelect.value = savedLang;
        setLanguage(savedLang);
    }

}); // Închiderea listener-ului DOMContentLoaded

   