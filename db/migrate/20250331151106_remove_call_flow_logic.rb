class RemoveCallFlowLogic < ActiveRecord::Migration[8.0]
  def change
    remove_column(:accounts, :call_flow_logic, :string)
    remove_column(:alerts, :call_flow_logic, :string)
    remove_column(:broadcasts, :call_flow_logic, :string)
    remove_column(:delivery_attempts, :call_flow_logic, :string)
    remove_column(:remote_phone_call_events, :call_flow_logic, :string)
  end
end
