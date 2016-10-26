function V = splitAutoRC(epoch)
if epoch.protocolSettings('RCepoch')==1
    V = true;
else
    V = false;
end
