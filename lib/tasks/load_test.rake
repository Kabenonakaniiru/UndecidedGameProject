namespace :load_test do
  desc "スプレッドシートからのロード実験"
  task :load, [:id] => :environment do |_, args|
    id = args[:id]

    pp "load start"
    api = Google::Apis::SheetsV4::SheetsService.new
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(Rails.root.join('config/drive.config.json')),
      scope: %w(
        https://www.googleapis.com/auth/drive
        https://www.googleapis.com/auth/drive.file
        https://www.googleapis.com/auth/spreadsheets
      )
    )
    authorizer.fetch_access_token!
    api.authorization = authorizer
    pp "load: #{id}"
    sheet = api.get_spreadsheet(id)
    sheets = sheet.sheets
    pp sheets.to_json
    pp "load end"
  rescue Google::Apis::ClientError => e
    puts (JSON.parse(e.body)["error"] rescue e.body)
  end
end
