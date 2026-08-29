using System;
using System.Collections.Generic;

namespace CabanaBookingApi.Models;

public partial class RezervareServicii
{
    public int IdRezervare { get; set; }

    public int IdServiciu { get; set; }

    public short Done { get; set; }

    public virtual Rezervari IdRezervareNavigation { get; set; } = null!;

    public virtual ServiciiExtra IdServiciuNavigation { get; set; } = null!;
}
