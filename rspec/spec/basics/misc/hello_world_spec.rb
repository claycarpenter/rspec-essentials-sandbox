require 'rspec'

describe 'hello world' do
  it 'returns true' do
    expect('hello world').to eq('hello world')
  end


  xit 'fails' do
    expect('bye').to eq('hello')
  end
end
