using System;
using System.Collections.Generic;

namespace CabanaBookingApi.Models;

public partial class Clienti
{
    public int IdClient { get; set; }

    public string Nume { get; set; } = null!;

    public string Prenume { get; set; } = null!;

    public string Telefon { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? Cnp { get; set; }

    public DateOnly? DataInregistrare { get; set; }

    public virtual ICollection<Rezervari> Rezervaris { get; set; } = new List<Rezervari>();
}
