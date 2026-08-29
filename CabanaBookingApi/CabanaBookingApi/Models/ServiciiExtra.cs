using System;
using System.Collections.Generic;

namespace CabanaBookingApi.Models;

public partial class ServiciiExtra
{
    public int IdServiciu { get; set; }

    public string Denumire { get; set; } = null!;

    public decimal Pret { get; set; }

    public short Activ { get; set; }

    public virtual ICollection<RezervareServicii> RezervareServiciis { get; set; } = new List<RezervareServicii>();
}
