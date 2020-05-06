require "open-uri"
class SMSApi
  attr_accessor :client

  def initialize
    @client = Savon.client(wsdl: url)
  end

  #Modificado, ponemos directamente la url del servicio web, si no, no lo cogía
  def url
    return "" unless end_point_available?
    open("https://wwsspadron.ciudadreal.es/server_sms.php?wsdl").base_uri.to_s
  end

  #Modificado: pasamos los parámetros adecuados a nuestro servicio web
  def sms_deliver(phone, code)
    return stubbed_response unless end_point_available?

    response = client.call(:enviar_sms_simples, :message => { "MyComplexType" => { "destino" => phone, "codigo" => code } })
    success?(response)
  end

  #Modificado, añadimos los métodos necesarios para la salida de nuestro servicio web
  def success?(response)
    response.body[:enviar_sms_simples_response][:response][:respuesta_sms][:respuesta_servicio_externo][:texto_respuesta] == "Success"
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response
    {
      respuesta_sms: {
        identificador_mensaje: "1234567",
        fecha_respuesta: "Thu, 20 Aug 2015 16:28:05 +0200",
        respuesta_pasarela: {
          codigo_pasarela: "0000",
          descripcion_pasarela: "Operación ejecutada correctamente."
        },
        respuesta_servicio_externo: {
          codigo_respuesta: "1000",
          texto_respuesta: "Success"
        }
      }
    }
  end
end
