using CabanaBookingApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CabanaBookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ServiciiExtraController : ControllerBase
    {
        private readonly PostgresContext _context;

        public ServiciiExtraController(PostgresContext context)
        {
            _context = context;
        }

        // GET: api/ServiciiExtra
        // Returnează lista cu toate serviciile extra (șampanie, vin, aranjamente florale etc.)
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ServiciiExtra>>> GetServiciiExtras()
        {
            return await _context.ServiciiExtras.ToListAsync();
        }

        // POST: api/ServiciiExtra
        // Permite adăugarea unui nou serviciu suplimentar în baza de date
        [HttpPost]
        public async Task<ActionResult<ServiciiExtra>> PostServiciuExtra(ServiciiExtra serviciuExtra)
        {
            _context.ServiciiExtras.Add(serviciuExtra);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetServiciiExtras), new { id = serviciuExtra.IdServiciu }, serviciuExtra);
        }
    }
}