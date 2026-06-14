require "test_helper"

class AlertaMailerTest < ActionMailer::TestCase
  test "despesa_urgente" do
    mail = AlertaMailer.despesa_urgente
    assert_equal "Despesa urgente", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "estoque_critico" do
    mail = AlertaMailer.estoque_critico
    assert_equal "Estoque critico", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
