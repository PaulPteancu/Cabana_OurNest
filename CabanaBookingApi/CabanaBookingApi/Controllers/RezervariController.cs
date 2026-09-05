using CabanaBookingApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CabanaBookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RezervariController : ControllerBase
    {
        private readonly PostgresContext _context;

        public RezervariController(PostgresContext context)
        {
            _context = context;
        }

        // Endpoint: Salvează o rezervare nouă și clientul asociat în Supabase
        [HttpPost]
        public async Task<IActionResult> AdaugaRezervare([FromBody] CerereRezervareDto cerere)
        {
            if (cerere == null || cerere.Client == null || cerere.Rezervare == null)
            {
                return BadRequest(new { message = "Datele trimise sunt invalide!" });
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. Salvăm clientul
                var clientNou = new Clienti
                {
                    Nume = cerere.Client.Nume,
                    Prenume = cerere.Client.Prenume,
                    Telefon = cerere.Client.Telefon,
                    Email = cerere.Client.Email,
                    Cnp = cerere.Client.Cnp,
                    DataInregistrare = DateOnly.FromDateTime(DateTime.Today)
                };




                _context.Clientis.Add(clientNou);
                await _context.SaveChangesAsync();

                // 2. Salvăm rezervarea (fără proprietatea extra dacă nu există în model, sau o adăugăm dacă o găsești în Rezervari.cs)
                var rezervareNoua = new Rezervari
                {
                    IdClient = clientNou.IdClient,
                    DataCheckin = cerere.Rezervare.CheckIn.ToDateTime(TimeOnly.MinValue),
                    DataCheckout = cerere.Rezervare.CheckOut.ToDateTime(TimeOnly.MinValue),
                    PretTotal = cerere.Rezervare.PretTotal
                };

                _context.Rezervaris.Add(rezervareNoua);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();

                return Ok(new { success = true, message = "Rezervarea a fost salvată cu succes în Supabase!" });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { success = false, message = "Eroare la salvarea în baza de date: " + ex.Message });
            }
        }

        // Endpoint: Extrage toate datele ocupate pentru calendar
        [HttpGet("date-ocupate")]
        public async Task<IActionResult> GetDateOcupate()
        {
            try
            {
                var rezervari = await _context.Rezervaris.ToListAsync();
                List<string> dateOcupate = new List<string>();

                foreach (var rezervare in rezervari)
                {
                    // Folosim direct proprietățile DateTime, fără .HasValue / .Value
                    DateOnly checkIn = DateOnly.FromDateTime(rezervare.DataCheckin);
                    DateOnly checkOut = DateOnly.FromDateTime(rezervare.DataCheckout);

                    for (DateOnly day = checkIn; day < checkOut; day = day.AddDays(1))
                    {
                        dateOcupate.Add(day.ToString("yyyy-MM-dd"));
                    }
                }

                return Ok(dateOcupate);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Eroare la citirea datelor: " + ex.Message });
            }
        }

        // ---  ENDPOINT PENTRU GET REZERVĂRI ---
        // GET: api/Rezervari
        [HttpGet]
        public async Task<IActionResult> GetRezervariComplete()
        {
            try
            {
                var rezervari = await _context.Rezervaris
                    .Include(r => r.IdClientNavigation) 
                    .ToListAsync();

                return Ok(rezervari);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Eroare la preluarea rezervărilor: " + ex.Message });
            }
        }
        // --------------------------------------------------

    } // <--- Aceasta este acolada finală a clasei RezervariController
}