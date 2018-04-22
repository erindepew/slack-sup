require 'spec_helper'

describe SlackSup::Commands::Stats do
  let(:team) { Fabricate(:team, subscribed: true) }
  let(:app) { SlackSup::Server.new(team: team) }
  let(:client) { app.send(:client) }
  it 'empty stats' do
    expect(message: "#{SlackRubyBot.config.user} stats").to respond_with_slack_message(
      "Team S'Up connects 3 people on Monday after 9:00 AM every week.\n" \
      "Team S'Up started 21 days ago with no users opted in."
    )
  end
  context 'with outcomes' do
    let(:team) { Fabricate(:team, subscribed: true) }
    let!(:user1) { Fabricate(:user, team: team) }
    let!(:user2) { Fabricate(:user, team: team) }
    let!(:user3) { Fabricate(:user, team: team) }
    before do
      allow(team).to receive(:sync!)
      allow_any_instance_of(Sup).to receive(:dm!)
      Timecop.freeze do
        team.sup!
        Timecop.travel(Time.now + 1.year)
        team.sup!
      end
      Sup.first.update_attributes!(outcome: 'all')
      user2.update_attributes!(opted_in: false)
    end
    it 'reports counts' do
      expect(message: "#{SlackRubyBot.config.user} stats").to respond_with_slack_message(
        "Team S'Up connects 3 people on Monday after 9:00 AM every week.\n" \
        "Team S'Up started 21 days ago with 66% of users opted in.\n" \
        "Facilitated S'Ups in rounds for users with 50% positive outcomes from 50% outcomes reported."
      )
    end
  end
end
