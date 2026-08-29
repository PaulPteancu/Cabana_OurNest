using System;
using System.Collections.Generic;

namespace CabanaBookingApi.Models;

public partial class Rezervari
{
    public int IdRezervare { get; set; }

    public int IdClient { get; set; }

    public DateTime DataCheckin { get; set; }

    public DateTime DataCheckout { get; set; }

    public decimal PretTotal { get; set; }

    public string Status { get; set; } = null!;

    public string? PaymentStatus { get; set; }

    public string? Notite { get; set; }

    public short IsNew { get; set; }

    public DateTime DataCreare { get; set; }

    public virtual Clienti IdClientNavigation { get; set; } = null!;

    public virtual ICollection<RezervareServicii> RezervareServiciis { get; set; } = new List<RezervareServicii>();
}
