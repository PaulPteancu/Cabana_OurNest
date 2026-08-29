using CabanaBookingApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CabanaBookingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ClientiController : ControllerBase
    {
        private readonly PostgresContext _context;

        public ClientiController(PostgresContext context)
        {
            _context = context;
        }

        // GET: api/clienti
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Clienti>>> GetClienti()
        {
            return await _context.Clientis.ToListAsync();
        }
    }
}