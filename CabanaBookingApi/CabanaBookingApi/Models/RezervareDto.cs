namespace CabanaBookingApi.Models
{
    public class ClientDto
    {
        public string Nume { get; set; } = string.Empty;
        public string Prenume { get; set; } = string.Empty;
        public string Telefon { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Cnp { get; set; } = string.Empty;
    }

    public class RezervareInfo
    {
        public DateTime CheckIn { get; set; }
        public DateTime CheckOut { get; set; }
        public decimal PretTotal { get; set; }
        public List<string> OptiuniExtra { get; set; } = new List<string>();
    }

    public class CerereRezervareDto
    {
        public ClientDto Client { get; set; } = new ClientDto();
        public RezervareInfo Rezervare { get; set; } = new RezervareInfo();
    }
}