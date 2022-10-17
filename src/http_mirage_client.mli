type t

module type S = sig
  type nonrec t = t

  val connect : Mimic.ctx -> t Lwt.t
end

module Make
  (Pclock : Mirage_clock.PCLOCK)
  (TCP : Tcpip.Tcp.S)
  (Happy_eyeballs : Mimic_happy_eyeballs.S with type flow = TCP.flow) : S

module Version = Httpaf.Version
module Status = H2.Status
module Headers = H2.Headers

type response =
  { version : Version.t
  ; status  : Status.t
  ; reason  : string
  ; headers : Headers.t }

val one_request :
  ?config:[ `H2 of H2.Config.t | `HTTP_1_1 of Httpaf.Config.t ] ->
  ?tls_config:Tls.Config.client ->
  t ->
  ?authenticator:X509.Authenticator.t ->
  ?meth:Httpaf.Method.t ->
  ?headers:(string * string) list ->
  ?body:string ->
  ?max_redirect:int ->
  ?follow_redirect:bool ->
  string ->
  (response * string option, [> Mimic.error ]) result Lwt.t
