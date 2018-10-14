require File.expand_path('../../test_helper', __FILE__)

module Stripe
  class InvoiceTest < Test::Unit::TestCase
    should "be listable" do
      invoices = Stripe::Invoice.list
      assert_requested :get, "#{Stripe.api_base}/v1/invoices"
      assert invoices.data.kind_of?(Array)
      assert invoices.first.kind_of?(Stripe::Invoice)
    end

    should "be retrievable" do
      invoice = Stripe::Invoice.retrieve("in_123")
      assert_requested :get, "#{Stripe.api_base}/v1/invoices/in_123"
      assert invoice.kind_of?(Stripe::Invoice)
    end

    should "be creatable" do
      invoice = Stripe::Invoice.create(
        :customer => "cus_123"
      )
      assert_requested :post, "#{Stripe.api_base}/v1/invoices"
      assert invoice.kind_of?(Stripe::Invoice)
    end

    should "be saveable" do
      invoice = Stripe::Invoice.retrieve("in_123")
      invoice.metadata['key'] = 'value'
      invoice.save
      assert_requested :post, "#{Stripe.api_base}/v1/invoices/#{invoice.id}"
    end

    should "be updateable" do
      invoice = Stripe::Invoice.update("in_123", metadata: { key: 'value' })
      assert_requested :post, "#{Stripe.api_base}/v1/invoices/in_123"
      assert invoice.kind_of?(Stripe::Invoice)
    end

    should "be deletable" do
      invoice = Stripe::Invoice.retrieve("in_123")
      invoice = invoice.delete
      assert_requested :delete, "#{Stripe.api_base}/v1/invoices/#{invoice.id}"
      assert invoice.is_a?(Stripe::Invoice)
    end

    context "#finalize" do
      should "finalize invoice" do
        invoice = Stripe::Invoice.retrieve("in_123")
        invoice = invoice.finalize_invoice
        assert_requested :post,
                         "#{Stripe.api_base}/v1/invoices/#{invoice.id}/finalize"
        assert invoice.is_a?(Stripe::Invoice)
      end
    end

    context "#mark_uncollectible" do
      should "mark invoice as uncollectible" do
        invoice = Stripe::Invoice.retrieve("in_123")
        invoice = invoice.mark_uncollectible
        assert_requested :post,
                         "#{Stripe.api_base}/v1/invoices/#{invoice.id}/mark_uncollectible"
        assert invoice.is_a?(Stripe::Invoice)
      end
    end

    context "#pay" do
      should "pay invoice" do
        invoice = Stripe::Invoice.retrieve("in_123")
        invoice = invoice.pay
        assert_requested :post,
          "#{Stripe.api_base}/v1/invoices/#{invoice.id}/pay"
        assert invoice.kind_of?(Stripe::Invoice)
      end

      should "pay invoice with a specific source" do
        invoice = Stripe::Invoice.retrieve("in_123")
        invoice = invoice.pay(
          source: 'src_123',
        )
        assert_requested :post,
          "#{Stripe.api_base}/v1/invoices/#{invoice.id}/pay",
          body: {
            source: 'src_123',
          }
        assert invoice.kind_of?(Stripe::Invoice)
      end
    end

    context "#send" do
      should "send invoice" do
        invoice = Stripe::Invoice.retrieve("in_123")
        invoice = invoice.send_invoice
        assert_requested :post,
                         "#{Stripe.api_base}/v1/invoices/#{invoice.id}/send"
        assert invoice.is_a?(Stripe::Invoice)
      end
    end

    context "#upcoming" do
      should "retrieve upcoming invoices" do
        invoice = Stripe::Invoice.upcoming(
          customer: "cus_123",
          subscription: "sub_123"
        )
        assert_requested :get, "#{Stripe.api_base}/v1/invoices/upcoming",
          query: {
            customer: "cus_123",
            subscription: "sub_123"
          }
        assert invoice.kind_of?(Stripe::Invoice)
      end

      should "retrieve upcoming invoices with items" do
        items = [{
          plan: 'gold',
          quantity: 2
        }]

        invoice = Stripe::Invoice.upcoming(
          customer: "cus_123",
          subscription_items: items
        )

        assert_requested :get, "#{Stripe.api_base}/v1/invoices/upcoming",
          query: {
            customer: "cus_123",
            :'subscription_items[][plan]' => 'gold',
            :'subscription_items[][quantity]' =>  2
          }
        assert invoice.kind_of?(Stripe::Invoice)
      end

      should "be callable with an empty string" do
        invoice = Stripe::Invoice.upcoming(
          coupon: '',
          customer: "cus_123"
        )
        assert_requested :get, "#{Stripe.api_base}/v1/invoices/upcoming",
          query: {
            coupon: '',
            customer: "cus_123"
          }
        assert invoice.kind_of?(Stripe::Invoice)
      end
    end

    context "#void" do
      should "void invoice" do
        invoice = Stripe::Invoice.retrieve("in_123")
        invoice = invoice.void_invoice
        assert_requested :post,
                         "#{Stripe.api_base}/v1/invoices/#{invoice.id}/void"
        assert invoice.is_a?(Stripe::Invoice)
      end
    end
  end
end
