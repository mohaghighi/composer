ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �9Z �=�r�v�Mr����[�T>�W߱je��y�� �H|I�l_m340b���B�n�nU^ ��wȏ<G^ ��3�������kN��>}����>���f(-d��1,�h��0G��m��� �!�g8&p�Oa��>��'�Q.���a��{�.8�M �&��l�E��R�"�R}l	[c!��*��a �9a����/݆���s���0�f�m��i�~��5����E��m�$��mn��!�m�4�wU���H�H����aI.�'��lf��2 �8�F�U�Y���v<}��F6�Ab�����Ŀ�����qO`4�!S��U��S 馡i�a%���&��JIN�+�!ڦ�(�6,P�d�:�\ܙ���\O��⹡#�ƝvduUC�;X�����a�T�yͯ!K1Վ��7�a M�.��Q�q��.?����P+نI�CM����8Nh<x5<�*Ԭ���md8d��7�0k��Sn����!-������B� ��펆Hvb\��=��gO�9�P�iEjt� iN���ɦH�C���JG�p��bKq��7m��ۯ����N�_\$"��9��쮛!�`����胃,�R<�3��Mm��>���x2ߖb�������� �Ѵx�#�׌��a��RCu�h��.md�P�%�{׹��|�]��j� �?���{��(y�Xd��G`���D�"/��Ƚs2�r�o����QFOw�נ�\�:�����!�GD<8>&
k�%��������j2��
��S���GM5Ɋ��LH����a����r�Y��?� :��:���<Y����S��>��*�\d-������0E���m4t($�6��"pg��0���Wk���a��w�҂���^��q����R?��GEA\��*�8������:�|q�r���:�EZ��D�,`���f�lA�0�	iF�8ű�i٠��3���1�.ފ0u�tM2�Wm����CoC�=���h�B8��T�+4���6�
���b�c7s���J��i��t��-a�i������3�gx�.K��\V5Ci)M8�ڳ��9�C-����n'[��VU���4�.=`��� � �wt'k�$`15
�w
u�^C��"M�I(�1�nC�h\�n��v7�������%���|�\�w�/��$MK���eM����s'�?.[��� ���<D�uG��y�nB�TMP���.����zct(l1�B�mt�>c>2�����F��X �����[�M�X���.`Y��%!��5)M���>B�jo�����
���y�^�OJ����ra�r�]�Y{�4rP�m�5ۀ�:����bz؁����)��z����B��hĴ���x�-f�-7�a�p�c�%���1i�+�c��Sݰ��i�:�#����Q�A �O� C���C|��S��1�9�]�;�X�ڠ��0&WpT�"����o7qG�8�Q)��iZXHC�zMUi�j6�`�����NN����X���z}Β��g�G��U'��x�36�^b&܈
R�&�eMV����K ��(o�|9B��y��v�˛(k]����,�05CG��k�)�?�H���%pw�o4���U����u����=ձ@�yQ�N�?ϭ�?+WOJ��0�v�:��f��G�1��X�(�V]�1MB /X�1�>��w?a5a�{��y)Y��w�K�q�/�bW���͏>��-�ՕWX�MK�b6y~,K���������c@���[�~�ut�i�
ܨA�IW�x�]/��A��f���%��9���%��M~Ke�X>/gs�a�<��1�i����Bx�jֳM+��G�6��D�[|���oҠ\���۷`sjŻ�&�߃�EBu˙��<��!Нv�,x���j��'eI�,h�d��!x݊'�~�l�[�<7Z�����E�W���<�Xr^D�2��"�O�����p�������Z�T~�eyL�ND�k��7
�Wu�h�.�#A �w��g��+����4��4 ���&��XXX��*���y�j�����D�@ �W��z	9&<d����V��0E�'���{�w��
���U���&�R�`��?��G�"��xr�s=���e.,��p����G���J`��W&f��c#ܴl�L�0_����w �nC�fb�P����&g]4�|sL�H����/���_滉���'�dKMǦ���ͳK��"9V߲Q� #�=��S"��)ӛ��tp+�)�r�{����2a���;��j$H�F��f���tx��B�j��Ş@ݘ�諈F)F��ce��?�8s&��{��N��5�>l��F(�@��*�on��/s)d��'����^�W˯�����Us����ㅈذᮥ���N9� ��d�@��?ԛ����� |����x'l�ݻ��ߩ�Q���X���[�_�R��ǲ>���Bd���˿'�s��z��`5)-7���r՚��C���� 97���+�0��Ys?*#�F��N��ف�����k�@:�>b*O7����3�(��}���m�+�������J�i�_���_��|���^��"�'��������'��j*�	9P�4�t��ӛ{F�UfH��3�P���5a��n8��|���m��=���>�G����B���U���?�O?�0^����5u�!�V	�E���>�2������|t�����
�Q7�v�9��-��|$d��Ⱦ�����`Ŕ=&�"��R�X]��sL{�c�����M<\��q�0'_�}�f�{-��f׆�f�83�Q1{,���}�t��e�7�~�6�ASW�uL���a���n�Ǖ��i~����&[��!�!�r(��9%����qTW���0"N��䔰�)�ߎ�x��A����[-&)�+��R:��YH��6
-�x�^ A@�-�g* ��;m��ekH�F���D��Q�:�%�P�l#݇��@�(�&I3��&�?>��+�4�z&�
^&8S�4|aQ)� y����� �v���+����V#ݫ�X��0�n;����2A��쿈8�%����[	|���8�n�VM��	�?�b�)>��[���/x�����iAA�E'�_�	��_+�e��a�»x�C?NE��+F������?����eH|�4�nav�4�*�t�, W8�a�հ���4xM�Q���1��v�6�$���׸I��%Ƶ=��Xl���E6G��&�H�ugdmxV6��>�`�k����í���
�	u�%������~�q%p��-b���/�Ax��/\$6y������+���eΙ��}����������+��'��F�*���߮+�qX��Ee;�֫qAb�<�b��
�x��ƶ#Bu;���o�?�Lސ6���[��ш�+"��w�_��m�����4t�0m�io���?0�l���}���oƉ��7�}3�ò��K���獿��/6��߿�Mv�a��>1��jZ���#��0��SD$�ԇ�%p~�>o���y�.�TýSw_���z�_|��=���c��/�1����U�G�����15�NZ�_� �/XX���
݇�X�{�-�Sٝ�,9�P�F�>v�,{t��P��>��CHL<@ !g�y@�'��lR*�4����f���dRR���MH�lQ�;��q�y�Jd�ƛ�j�-��K6N���Y�ꂓ1nO��0������h��ǹK�J*&�cL��l�Ռ֮�_;�D�L_H7O)��q��ȼӕv�9��Sa�2S�޸FY���gW�s��٬�IXg��EU�.�RtqreY�7���������ϕ�^�"+��YNH�M�i����D5W�z��i�P�Ƚ�Ǖ+���GZ�L��Bڂ'g]�霖�\���2��W�������'��&Q���G1�^�pR��ID�}��JeҶ�����n��8�=��e��RN�K9�Lz�{��e�D��޿L�L�T��X��z�r��)�'���Ğ~�:9�i�J��K�iX+�j$;��uz��|)��r��b�L���Fo��\N�$�涖�ɉP�@�x���r������Tߖ�I�%-ҪZ�Wh��R6�6ϠKd�w�Y<h���:m,Yxxhr�t4�
�#{x�;9���`R�RN�$���h�������P-�"q^�#'�PS?{Ke#���Tz��n�jd��~�h�_�kFڐ;P��r�Sz��9��AN�'�x�[�W���;�Ny9��"���u0�|`�Uo=��[��^?���Ș.��|������3���4{ޢ�_)|����� O;~aE���O���y~����I^�ؗOi�c&����=Y��G'2\�Php\�wp��7�P\mU����C�+�oP>s�i]-�B�Uq��N�\II*�ݤU�䋝\�u�����c��Ԍ�U�ẍǭJ�P��#iE*�{BFm$�'z�0���H�T�����j�D�i䒏���w�a��׿X���{A����"$$d-�+�9v����,k%1�I̲6����,k!1�H̲���y�,k1�G�4ۈ�i��c��_��'޴�"k�o���?������G_��'L��ֿ������A6�7�ҭ��;�����T�x)���
I���)�SXN��]�4��ţ׍<j�3�a�,�k�Hq�go��t1�4�8�����+[�ۺt��,�w���:z���)����7�&9�ܽ�ہO�߭�`���u,�����ߑ���VO@���M�M��_f'$ME�f�"��d��(��ԛ����7�,��"s�~��a��������f�bA �P]�U1k�IT��ZhC6�UI/j�F�>xq�,��!?-}��	=��� y�#أ Hm��;�_K��nB�-u�BG���rEzT�f�h*Yj�}5�L=7���o���a��/�{s��'򠽷��$��A��������A'o������=}�~E'�,�=
�I�:���aUs�B�$�M�ɏ����L'�@�pL���Q;&�WA rЛ��G0�A�>�L^[-#�}�F/\it)xth��@P�4a�TH1_��"Ӗ�0J듺-zo��=�B�y��dB� xZD��@�I���AEP^ ��{/dЃ>:��g�YbI����"g��;vIj�oM����-m�3m���o�\6�R�3��r��r���W��Bڅ�@Z�\7ܐ�WX�eB�q��7���]�O�t��Dg�]vdċ��Eċ����c7>�b���q[��r��^����`M��Lu_� n>�l���.р��a�Ύ�	�pcĮ|���~�?~�������@��42���c;�v��E�A}@#')�@�$���)9U�	B��j,�j������M��#wR�%�S.���v%<�0/�F����0�?�VP��F!�u��݈���$L/I_�s�)���T�Lg�m��P�4F�9��J�I0U�+"�F�o�K F<��ËTb��~�Cս��!Ɠ3gc��]ǜA�\�%j��*�KB�#\��O]�n�_1�|5V��Q����u3 ��庮@�ɞ�z�L*�s�������ވ���
*5��34 �����
�x�UR6��c�n$+T;д��!�n�0_�Ս{9��C��c�C�:z 7�g��݋��H<�t����V���!��$�[;�}�~�4=~sxhrw�Բpl������H����C�,�Jc�(��N��S�;j���]�����MC	m=�AL�����?��Ƕ��)�zq��<��}2^�"��?����s�/ޟ�U�o�x�s�����������7��K�w)�3��E,�_�{�͗￶�C|W�u�u��ԕO��H�3qE1��+�TZ��GgY�SY5�L�d*�M&zY:�&3
E��>�di%�$i9r?���_��q�S?�|�+?��ON������$�;1⻱�o�"��6������#�}{������[�E��~���#�"6k����^��?��7G��5LCW���1�:���\I�2�ցm��E5i���c�XM;Ϫ�z�c��::&n{v�����������̘�//D�C�3bwFF�;�Ee���Yg!�Փ�Y����V��(.r+���w$�8�Ć��n�ޙp��b�e�������g�"�P�BBk�KyT����\l���3����(���6�ȅ֬Cgm��8��~Q9�4��3�`���i*�a��ph��Ғ)��A���n�v����:�Vve ���a��䫥z�Q<��`��W�M�ܙ��F+3&���1�C�l�jL�e8�Za$2|$^��#2�������Yr3�����	>S�'xA�k`�i�׊���$����n)��Dj^N�e�3���Ķ�׀ ���ӳ��:���5�&ٌ�\��Vjz�M9K�q��Qy���k%S`�n��Sg��DNIՅ=�	U�z_�[��g���-5�0*yaT��Ϩ��*�j��Б��g2U��k	��!�s�~~"Q�,{��R�J7f4r��E�C�X��b[),V�=_F�(Q,vn-z${n'z2NV@ ��/�1�x;�C���d�_�R�q�QH�f�K��T%n��n[j�Ζ�</��v�*�B[�xRb�s"���T"��n�1�l�dJ���1A?YO]/~_�<��IwM��c�� �-�2_�Ti�H��9[9T/�)'>��;���2S�'�U����lJ�F���t������ֲ�2�K*9�	�I9��9�R�*_��V�U��j��s�?��s�y&5⯠���n4���~��^��ً����������]O�
��7|o^¿7|���ooy��rh��<����[F>�����Ȟ����D�|Q�&�A����/��D�`[^��y)h�e�"�j-N�|�ȿ~�rE~�����t/��{�߻�G�~-++� +S�Z�vf^�,����e�O7NRJ�wA��Y��<�4}�������]���N�<�\�m�f
O�s�њÜ�pYW��5�u9�6>ٖρ����5�(m��X��	�]�ed�_��v�XgWT����r��7����:�M�����Q��(&ȝ�>�պ�Ѡ�br#Y�Y��c/�	���۫�Q���¤tlR�8����e2X�c�:>G2�t:����w�cja}���L�Q1�qAᴺ��X ��2QMgZ��A�� ��A�<�h��:��9h3Bg�b��A�U�����'�rX;)Ȕ4h�F�TLRO҉�IjZ,)G��h�rzTB4Q���U��Tt���A�P��q�-��ў ��t)�ë��߸�hrHQ�E��)E�5���r�ϔ��64V�������
��/o+��s�+�ܨ2��#P�8�$>.r�e�_V��b�0MpӸ �9>��>���w��	��1�yP���1�n&�rU��������=׀Q+��N��f��.W��j�=��zk��W�!� �FY��Nc��Rpqu^j�8��Ά�n�I5;畊�[;D�ʈ��*ʼ�(�D�q�\b9csuG0�=Z�IS����/.�џ�ۃ�#��{A��s�X�J�Q݄ ua��`v�;���B�X-�C��L�R3=/l�/8#p���ѐ �h������0W�>��{�c����bT��r���)�ꏞJ'��ki�"!A�\�2�'�==�,[V .^�J�{���t
�'Hy_4��n���[0�0!�z����/LH��
^�^/P��q��:��&V�h�x��<2�#>;����YL�Mg��zS�h~u M(`0�f�M�v����V�<��*3��Df5�"�r[�B�e�@I���<~����+�T�;u�4��Ƀ3�^��)1	�(mq�@�����73,�%Jɺ��QI��t%��$��1��0�J����d�V�Nsщ��HvD6���X��r	c)u��v�Y�*1zi|��~�&���үF��nA!:�o^&�V�o\(Ё����ղ��{*��3��e�g�n�:�f�����7#��Z�aY���a��4��y+����'O�w�<!�<�$��y$�Q^䫑W�W�g�O���������2^�n�M�Z�D�8}@�Y�@k����`�T{�c�A??���x���s6�C�����Z�] ��&�Q��jY�IF��z�O�t���ҵȏeT����/�/�����ً������X*~��O�N�8�{����"i��3~p�$鹞�~= 9��W���K7�˩��0d�Tq<����&Y�u��A���)�6vnz�h\l�Td�g��g�/�G�!Ax�M��<[p���S}ҷ�]'��[�:$?��p�U���a#t�fY��'�ݞ�m�u����֋ ��1��3�@�"�pG#w�d� �14����лB�kt�َ ǥ�%�kP�B���9�B���� �)�� �OU\��Y�L����}Sѻ@��a�����}cj���<�6^8�w�$����Pȱ
e�2�������;^���y 6��t��VöU&�a��sQ����x���'�\���xc'��o�!x�6�u��C��UÜ`#`u<ק�}�l��ƅ�	b](R#��F1d��X/p�)����oۊY��s��5/��T��;0�!�J�Z���+'� ��"��>"�T�����It��nX���>�!�0!D�Y�A�'U�~"��[O$>f ���0���#X7w�i��St�`�þ~�1�ߺo��]���D��א���iY�׿���`6��?dȢӳM���hjͱgѺ��ބ{o$6x�C�%�Ј8ԅ�͵ >Ľ�]0l�85YR"��w'q��$T+�k@����_D��q��Q>	���b��0�i�+YS����k��n���)�<����I����q�D��*�R�߾�Vƾ��{�t��Ѿ�>������f�^n(�[w��^S�򲅷�\��Az�n{�Yyb��Q;��~�Al@�D( eT�	����	m� =klOM��2��&� ���x���1�����̎�B�F�*�`'�t���gC���,<h�r,\#�q�Aَ�e�6dw�����(�pb:��u�"^�Nu`�n)�&��p��*`�^��)���հ��.�l5o�x��#?*|S�����e�~�!��~�Fl�M���f����tv= I�&��9Btr����C$`�q�;�u�������C��2�B�*U�?�9��!�76�M�įk�MSt�a����,����y�j�7�D��f!N�2M�[P�:���<��n���8x:�X�s:��Ʀ��̙�ɱ�#
@Hp>q^!��Z��d��z�	^�?O��w1�ٵu\s�?����?'�������x!���	���s��1�\^����  :�Z��Y��!�Ns�)���(�ڽ�NpN�(���|}�0Ď��]U
���*_�Z/�zeEG|���4��~<��i �d:K� W��~*����>��� �����"��~6��
�@m�!��ܾ�"l�a�p��j�������/� �`'�n�՛�bǄ���˧Ie��JY�c�L,� ���D/� �T*�UӱL*�Ɓ��B G2�Ui�)�!�n��C�9q���z�����O����7�7^x�S���.,�w�v�ߑ���J܌l��o@�.����O��B�?�ˏU�i�g�_a8��7��bX��]��m
M���U���&�n��w�/��vE�rLYl��Qh{��(��&���� �}�{�";U��LԜ�Q�D�jQkڋj�=���.��&��*v:Z2�������E4��k#�Sn��a�;���Z�G־{�d7�_��r9ʣB7��\��#$/��i��[���犌P�U�uN�&8�m6���|��U���h6���hݳ���4:��=���O\U~
1��ݣp^��.M����6��;�E�զ��V�B��K�j�H��{��i���f���nH^�S]�5F*^����X֓�sX�)�����c$�e����9�8����j+W�X�O�/�z��"&���3%��oK GQ�o���G}`X�%$LmN�7��N^F�n�ԗ��H>�7ݍl�)k�oY/�c����W��NԱb��wn��<�@��ǎ����w5��Als��G��F��cO[�2�b;p**�h����閎_����‡E����J$c��_������Fw���������������}���өċ��O���$u��w������=�ۆ��	���r�ض��z�;'�P�N�Q!��&'�!D���te�!˙��֮�������n (��;���A�������Z�9��G*���KU��T��O�q��7����H�4��6���4U�,����/�H@���H�Q�,&Er&�u��"�`�pa��$�T�")Θ��&X1�(�X���}ԧ�s�C���ԝ�c��/$����>&���.f�I����v5�[{�6�����唑ԏ]�7���yt���ӟ�Fݪ��Y_��0�[��21��Wa�/=s,�5��}*g�rz��yp���!��UK1��&~�Q��J��������ǃ����������R������'�OQ��G�O����?
P��7z�~��������.�������x*��[�v�o�����r������$`��O���F �����r���{��A�Q���?��/t�����S�'K����C�pT'�	Gu��[8
,�����?����}�+�����������?̇V �?G��R��	o���-����j��;�a-_��V�e�a���������}���F?�����=FX-�ݳ���O�}��E�|>�U#����>_�>��CS�T���2��پ(먳��;�L���짻̤�ܞCm��Vq.7�mg�oՖ1/��R��7�C��Dn�=��2�I���g��W{!ӓ��ǁ���k�ks�|��'ǘl/��f9����7�>��aQ_�2���ʉ�$����v�����X5�BmZ��c���*r��ü/77�|���{Η����pf�8����4���A��20�O�����?���B���_x�?l�B����O�������`���6���h�(���ei��U����X���g���ρ�� +��$�?�����7����?�����TLsy�Ӧ��?�~��#������KX_x���R��o��{��p'��i@��`�g}ue%� w������5��aڼ���b-�������ZJ��ٷ����N�C�#C����m��SXO�=��eK.��z�y&@�d�0�C���:����V�'^���[�w����s�dS�U҄�H��h/yzk�x3�/��pPlF��M�l���������E���2�WL��Q�(�u�z�8i;�Fk{����o`���������2�d��C�_�n����3�>O�������?���8*
I��8�X�#9I
b2f1�PC�g|^i&I&�C�����I8#���A������r�Vv<sqN�m�ި�<�m3�t(��n-K5�T�k�O���e��#���9���)����I�9���#���t���ɹ���v��0j�-�=մa�G�.�6
v��K��q�?~Ԃ������Y���T}+��?�Ձ��C�Oe`�����kX���	�A�!���_�mGM�vڌ!q��ן��N���A7�[��g��K��w���ԤWO߾d|[����ϔ�91+�4Tճǒ˄�'c���p��.�Bi͎��;^|�����ˤ����A����q��!�[��C����;���p�������/����/������j�?�� �'w�������-��W���_���6o����s�(=��ӻ��Ѣ�������ol�qu[�9�xz�'�  ��g�p��as�
�C�J�x� �9Ͷlh��Z'�2f���Kr�fD�֨+f�0:���u�~S-C����QG0'���n��vPυ�]ݛsXHv�Y//,��s��q��%���=�^�v�3l(��\ぃ���j>	y�ti_nՓ����H��*�C;V�5��hO����lvhf��<O 8��Rjjc����Q<�ԴJ(��'ܟ4ʖ>2I�p�5�btl��R�N͖��әft6Ė���#v�-�9U�T��mwpQ^^���b����ErVl�>�,ms?��4���Q��ǂ�C����C:<�����G��p	�(�A��W�����H@����[P������������a����(���$������� HV$�ȏ(:fCҗ|��yV�R�Ř��v���t$J1+Ĕ��1v~8�����?�ϯ�����qY�!7]ϽMpi@�F�z�삝��[��n.������`�K���uKvam7F�#���x�}b�f��.]�I�����]�/#����J���?��ᐖ:�*�^cp�̺�����}p������[�P��������?O���G�������h�ߏ�)�x����������0����/�~�/��1�����w���
���~������o��݌��%�+��v"�[}�r���ò��oM�_��uڞ?��}{�����[)�����;�~�9�q�Z�7{��G�<+�\�݁5�vN�=I��x��6'��A[im:��HX����o�fÏ�4�,��]���+������fR���@�X2�$n�\�y���ڶ�;ڹ����b(q�w������n~�{ �o�t�k�����NdK���������'�`0�Y�/%n,���&h���I'5�'F�r&�]��K�ml����%	G����V�'Ӌ�J�)��}�ld����n���4��w���?���A�i�����V��7p����4��C�C�7�C�7����}���W� ������p���Wr��� ��E��`�/-@�����a�/������`����������/��u�Aq���3�#��I�>�g@�Q�J����m�j@�A���8��**�XQ1������?�`��?0�XQ!������?�����@^��!P�J�t��� �`���W�p�X�?�.�������dH�@����������##����
�!������H�����?����������r�
���s�?,��������r�`�?�����$���� �`�C����������������������������GV�����!�����������u�S`���������2�d��C�_�n����3�>p�:p�������>��� 2�8�x��J,��W����'C�%C�_
(��%�e9��G}�_p��� ��������1�F@�g�ӗ��ٺF��?E�J�,�[n�q�4�NG1�i]J�Ox]yD��$�����jhqX�MgC�}�Ve�8��3��;k�,�*���VW�Z';Z/N��p�U�G-��&�|�n��A��i?����x�h��cŚo-�khw���~�1��?��������
���������B����20�����5��������Uǯ��z!cq�Z�����y�3��֢�����lP�s~�w�����e�ݕ]��nm@s#JWG͙M�$aw���g��0������~��Ow禼��-��e�]=.H�4��~���uΆ��{���w�;����?����{�o ��/�������/����/�����6��
���/���?����-��}������)��Q��߸'[�D%q����5�_�������i��xMj,�@�{v�1�����zM;-�=Ϻ��.H����ǩ�ʢ��'��I�<��ر�s�/�̥���l��v~ǖl�;���jn��ۍ�/��m��ӥSo��ΰ��r�,�Do(����-��a�.�˭z��b�y)Z Re~h�J�NQ$�I�q�����~X �-�Q��p�{I���
&��I�����iD�ϝ�7s�G���,=SN�?�j#u��AE�r��"I��ɮ5�j�q�,�͎��~�Y�����!��o��Ə�I���/>���>��ǯ?C�p���C�G����7>�����Z�����q�gI��G�O��}���G���	;=�������u���j��P�V����]��������m&�p�(I�Ds���*pE����Mv_����b�h>gܴ�z�������a5�����s?^R~�ל�S�ɗ�o��N]�����.����-sy�ZB�um�x �$��i5��YWKQ�[C���0�p�ꮖ�+��=�\�׺tЛ�r���<���s\#���6�Q�J�ܩ]甼C��j8܎�MfU��SJ������b2���%Z�)���}�/�����J2�o?˚�{I�OO\rZuK}�LDZ⤊���t�gj��ߔ�S�lS8I�To9\m��P;K��Z�WY��nɚ�˩B�;�+*T¶9'8).�eo O&ҹ'������ں��H�tX���=Oɣ�
K�ϹS��^���e�y�Xr�ڪ���y����]�����	G<���0)���R��a���^o��l
,#�|F���8�(?&C*����������C�~e���'3���G����$t/:LGAo�/�q��=ΘE��S�/���v�n�x�]�����^>��K����Ñ��P�������A�	�����������ǁ�C�[��Ny���_�F.���,Uz��b�B�G��.�����¢�N/����-�F�/����ݏ����-�G|G�ob)×�_�%����#�/��0i���-�ȫ|���zqc��c�'3�֔�]�F0m��5��Rs��0�5���r&���d�h'��k�ni?�y���� ��z�N����p֬��� �~s����|Ѧw;��tY�&�8�'�����M����w��jj[�;���Mݺ]�l�Ю>]�ߏ��\@^>E�u�{�v����NN6p�UI �R�s�9���p�����0�rҎC�4����HG��Y�Z{�aA�j�͹�M���l�6��B!Q]n����{���]��G������T�B�O��N�].�X�,D2���+�1S�(W�j���.��q�P	�����J	��i|��?�Wz��������b�^{n4EJ�:�P�ƪ^<���ǪQ[������4��uْ��Ge���o��'�?0��%�Ky��ڻ��4���&����c.���5���WvH���60����8��]���*�����?h���NT���ns�h�F;�vv��������&'_�_��(���e���e_L�OD9��R�:=�±U][�M�M>o�~��B�2s�����e�
y\�r�N�.�)ť6^����,���>'�tZ�����po��N�CL�`�k�fծ���V-.�Nw�㓸���k�,�g���mW�n��Kt�b��t�j5������6����p^��o�lT?��,8����Mjcu;�l����Z��"3��u������p+�,^R�WV]�����l�MuW�'�!�F�R/ù'(}f� \ɔ����5�ڡ��kUdY�I撯9������P�Wl|�`8F�.�)+�_پ�O#����7����4�]��?������_���i�?$�������?�������O����O����V��c8��߷�����vH���.g�E�����0��
������������[���տ��K�א�����?�A��r��̕�;���t��*�z�� ��?{����㿩 +�O���w �?���O�W���SJȒ��"{ ��g����_p��4��_������C�����
������~��������T���������}�\�����?RB�*B�C.��+���t ��� ��� ��������= ��o������̐�_��������!��a�?���?���?d;����RA��/p,H���߷����7� �+��!�?+�"����� ��������\�?��������[� ���������y��~���)!�����Vf攪WH���Y!R7չY*S���\'i�4���H�`L��h�c�V?�_y��}�C�:x�wz�(�
uaz���k	l�kJ�q+��d%����O�#��IX�&cݮEӧ�A��%������Rm�N0�J8\�Y�k7y��&�Ճ�k�[qT��"Q��r��,��&��i��\!�=J�T��(�9�v,Qi�夙[����c�2o�z{PYbUOq�㽫�ʺ�s�<������������y��!��y����Y����00�V�_��!��?3��T�IH;��!��Ð����n��eY�i�gv���Y��%���e{�j�kM�7=l+���d��pt������RY�owL�V��m�����1����B��XJ��6�@={<��E>����f�,�]}��_�Q�B�E��e����/����/�����h���G�����/|���Q����_�e����F�ő#	\��~9�'N��{��*'r3	��%���f_�!/G�XLf��7�RF����k��X�F��N�L�#��Č��-`�97^%�da���1�Gl�+u�Ԯ�������PB}�U�m�%����|�"����G-�
���9K��^},S���֒��>j����@�b��#�77��:�+5�Kɇ��|r��D�X�=�Z��wq�+�bsoV�jW|�8���)5��0-���b�X��g��b�N�Y�h{Dj��@�Q[�0�];�l���k��ȃ��)��
o��? �9E������������C���#��ܨ�b���@j������	���?k������
�?d��IX�p� ��Ϝ���?0��
2����g�������������� O�.��#-��>�ǘ�I��H������x�ȅ��o����K��?X2S@���/��?d���?,��	r��������o�������C��� p�7>��7��~U��ҭ��#��T�Q��Ia�c����ڏ�Ð?S���~ ����4����}���o ���햜�_�r'\�1;���b��⢋T�9���5�j�1Y�֊��̜���,��=�(<�H6(���d-*�#{�()�E~���R��ܨ�U5�v8�vhJE~Td�P�6[V���T�o�1+O�'��ܮ�e��q\v&����z=±�1a����[�4����HG��Y�Z{�aA�j�͹�M���l�6��B!Q]n����{y?��0��2�/Ϻ-��߷�����f��?��Q�T��������� ��������+����������{^<릸K@���/�Oa��!G�� xk�"��������ZM��_�?*��^�Cv�Ry���As2����E���G�d]�'Z{}�[����R��G5 ��>� ���V��>�q�*a��rU�Q��(ʬ��MY����BcJ}#@9�o�x��M���,�l���C�DG�-��k���  I���@�"�?��El�cek\_��]\f��p1��vd�eFQ�Š�w[{��uy���ʺ%��J-4p�b���Y����tQ3'x�i��ˇ�?�\�?���/���
2��Ϻ%��߷�������%��4��'+$��%�4iUW+e՘�0�0)L�I�� �rŠp��T3MJ74�6*e������~��2���������t�3��03��nYkLgsBFv�-_�z�`2�s)ӰR���y,7�ﭢ����GV�;���Z�V�������������B��Q\��%t�p��k�,���t ;آN`���"�?�f�L��d���Α��������̐9�?-��Y7�]"��_v���7ޭ��B�:�¡s��KR/���o5B�Et���EN��^�?����p�%<ϫ����%W(���B���F�+��F����v���)Fؖ4�t��vV��;��U`N.I@��Z���������������
 g�\�A�Wf��/����/�����Y����y�U�����Ɖ���g�װu�����El1�[̽J���뿧����~� �,��������p���"�0^Q1���?�v��/m�UZx,�*�-�Y�	�4ݟ�{]j+���<Qj��{������ڶ�Ղ疧�e��<Ne�Z�I�q��*ף)�u�56J���E.j�_� �
�'��G�a�+�%7jJY�y=`msS
�	KSҮ�a�������*6� ��,ge�;��Bz*�>�[<�E��@��CN�ꦧԌ�'�<3�N��.h��Ǖ5;�́��d��o4����2�+aæ��x/�G�bk����·S�����/'����Mn����?�����������g�O�t��O���2�B�����(|x��{���8��Q��"��d�#/J;����θ�����>x��tVF����RA�?&p��.�v!�����ç����AKv��y[u]cu9���?m^�T?o����k�Z��~ڒ�����?yJB�q�C`�g|c���������$�<�o����9.���� +',l܂��AX0|��������*yb֪;���}���z�;~�����7���~���U�1�����Y�U��FA����o������T��o�������?��7�{�o���>���/�/���+�����^�y�*>+r����߅yLɳ~~������{}~��q����?�4;��a��h��Mhn�B���ʘ[�_8?9�pSx|���WW��o�s+�Ȏ9�߹��Z�U�d����g�	��Q��{��7�8��B{8���W��|��[k��?��ۛ���:�w$X��ս�՝���}=�����k0�g>���-�e<���r|A?��æp#��/������हQ#�Q����K'p�ϓ�U6���K�[��M<|v����	;�����w�vK������"�Z�]���y��/?)9�ݫf�\���[��&              �/���Px� � 